//*****************************************************************************************************************************************

//part of the source code is from nanoflann lib at https://github.com/jlblancoc/nanoflann

#ifndef  KD_TREE_SPACE_PARTITION_HPP_
#define  KD_TREE_SPACE_PARTITION_HPP_

#include <vector>
#include <list>
#include <cassert>
#include <algorithm>
#include <stdexcept>
#include <cmath>
#include <utility>
#include <iostream>
//#include "../../core/definition.h"

namespace KDTreeSpace
{
	/** @addtogroup memalloc_grp Memory allocation
	* @{ */

	/**
	* Allocates (using C's malloc) a generic type T.
	*
	* Params:
	*     count = number of instances to allocate.
	* Returns: pointer (of type T*) to memory buffer
	*/
	template <typename T>
	inline T* allocate(size_t count = 1)
	{
		T* mem = static_cast<T*>(::malloc(sizeof(T) * count));
		return mem;
	}


	/**
	* Pooled storage allocator
	*
	* The following routines allow for the efficient allocation of storage in
	* small chunks from a specified pool.  Rather than allowing each structure
	* to be freed individually, an entire pool of storage is freed at once.
	* This method has two advantages over just using malloc() and free().  First,
	* it is far more efficient for allocating small objects, as there is
	* no overhead for remembering all the information needed to free each
	* object or consolidating fragmented memory.  Second, the decision about
	* how long to keep an object is made at the time of allocation, and there
	* is no need to track down all the objects to free them.
	*
	*/

	const size_t     WORDSIZE = 16;
	const size_t     BLOCKSIZE = 8192;

	class PooledAllocator
	{
		/* We maintain memory alignment to word boundaries by requiring that all
		allocations be in multiples of the machine wordsize.  */
		/* Size of machine word in bytes.  Must be power of 2. */
		/* Minimum number of bytes requested at a time from	the system.  Must be multiple of WORDSIZE. */


		size_t  remaining;  /* Number of bytes left in current block of storage. */
		void* base;     /* Pointer to base of current block of storage. */
		void* loc;      /* Current location in block to next allocate memory. */

		void internal_init()
		{
			remaining = 0;
			base = NULL;
			usedMemory = 0;
			wastedMemory = 0;
		}

	public:
		size_t  usedMemory;
		size_t  wastedMemory;

		/**
		Default constructor. Initializes a new pool.
		*/
		PooledAllocator() {
			internal_init();
		}

		/**
		* Destructor. Frees all the memory allocated in this pool.
		*/
		~PooledAllocator() {
			free_all();
		}

		/** Frees all allocated memory chunks */
		void free_all()
		{
			while (base != NULL) {
				void* prev = *(static_cast<void**>(base)); /* Get pointer to prev block. */
				::free(base);
				base = prev;
			}
			internal_init();
		}

		/**
		* Returns a pointer to a piece of new memory of the given size in bytes
		* allocated from the pool.
		*/
		void* malloc(const size_t req_size)
		{
			/* Round size up to a multiple of wordsize.  The following expression
			only works for WORDSIZE that is a power of 2, by masking last bits of
			incremented size to zero.
			*/
			const size_t size = (req_size + (WORDSIZE - 1)) & ~(WORDSIZE - 1);

			/* Check whether a new block must be allocated.  Note that the first word
			of a block is reserved for a pointer to the previous block.
			*/
			if (size > remaining) {

				wastedMemory += remaining;

				/* Allocate new storage. */
				const size_t blocksize = (size + sizeof(void*) + (WORDSIZE - 1) > BLOCKSIZE) ?
					size + sizeof(void*) + (WORDSIZE - 1) : BLOCKSIZE;

				// use the standard C malloc to allocate memory
				void* m = ::malloc(blocksize);
				if (!m) {
					fprintf(stderr, "Failed to allocate memory.\n");
					return NULL;
				}

				/* Fill first word of new block with pointer to previous block. */
				static_cast<void**>(m)[0] = base;
				base = m;

				size_t shift = 0;
				//int size_t = (WORDSIZE - ( (((size_t)m) + sizeof(void*)) & (WORDSIZE-1))) & (WORDSIZE-1);

				remaining = blocksize - sizeof(void*) - shift;
				loc = (static_cast<char*>(m) + sizeof(void*) + shift);
			}
			void* rloc = loc;
			loc = static_cast<char*>(loc) + size;
			remaining -= size;

			usedMemory += size;

			return rloc;
		}

		/**
		* Allocates (using this pool) a generic type T.
		*
		* Params:
		*     count = number of instances to allocate.
		* Returns: pointer (of type T*) to memory buffer
		*/
		template <typename T>
		T* allocate(const size_t count = 1)
		{
			T* mem = static_cast<T*>(this->malloc(sizeof(T) * count));
			return mem;
		}

	};
	/** @} */

	template <typename ElementType, typename IndexType = size_t>
	class PartitioningKDTree
	{
	private:
		/** Hidden copy constructor, to disallow copying indices (Not implemented) */
		PartitioningKDTree(const PartitioningKDTree<ElementType, IndexType>&) = delete;
	protected:

		/**
		*  Array of indices to vectors in the dataset.
		*/
		std::vector<IndexType> m_vind;

		/**
		* The dataset used by this index
		*/
		std::vector<std::vector<ElementType>> m_pointdata; //!< The source of our data
		std::vector<ElementType>m_ratiodata;

		size_t m_size; //!< Number of current points in the dataset
		int m_dim;  //!< Dimensionality of each data point

		/*--------------------- Internal Data Structures --------------------------*/
		struct Node
		{
			/** Union used because a node can be either a LEAF node or a non-leaf node, so both data fields are never used simultaneously */
			union {
				struct {
					IndexType    idx_region;
				}lr;
				struct {
					int          divfeat; //!< Dimension used for subdivision.
					ElementType pivot; // pivot value for division
					IndexType    idx_sample;		// index
					ElementType low, high;	//boundary for the box to be cutted.
				}sub;
			};
			size_t depth;
			Node* child1, *child2, *parent;  //!< Child nodes (both=NULL mean its a leaf node)
		};
		typedef Node* NodePtr;

		/** The KD-tree used to find regions */
		NodePtr m_root;

		typedef  struct NamedType{
			std::vector<std::vector<ElementType>> box;
			double rat = 1.0, volume;
			size_t depth = 1;
			double m_attribution;
		}BoundingBox;
		BoundingBox m_rootBbox;
		std::vector<BoundingBox> m_regions;

		/**
		* Pooled memory allocator.
		*
		* Using a pooled memory allocator is more efficient
		* than allocating memory directly when there is a large
		* number small of memory allocations.
		*/
		PooledAllocator m_pool;
		double m_lrat = 0., m_srat = 1.;
		int m_lbox = 0, m_sbox = 0;
		int m_mode;
	public:
		PartitioningKDTree(int mode) : m_root(NULL), m_mode(mode) {};
		void set_dim(int v) { m_dim = v; }
		//constructor based on empty data 
		PartitioningKDTree(int dim, int mode) : m_root(NULL), m_dim(dim), m_mode(mode) {}

		//constructor based on the pointdata
		PartitioningKDTree(int dimensionality, const std::vector<std::vector<ElementType>>& inputData, const std::vector<std::vector<ElementType>>& initBBox) :
			m_pointdata(inputData), m_root(NULL), m_mode(1)//???
		{
			m_size = inputData.size();
			m_dim = dimensionality;
			m_rootBbox.box = initBBox;
			// Create a permutable array of indices to the input vectors.
			init_vindPoint();
		}

		PartitioningKDTree(int dimensionality, const std::vector<std::vector<ElementType>>& inputData) :
			m_pointdata(inputData), m_root(NULL), m_mode(1)
		{
			m_size = inputData.size();
			m_dim = dimensionality;

			// Create a permutable array of indices to the input vectors.
			init_vindPoint();
		}

		//constructor based on the ratio
		PartitioningKDTree(const int dimensionality, const std::vector<ElementType>& inputData, const std::vector<std::vector<ElementType>>& initBBox) :
			m_ratiodata(inputData), m_root(NULL), m_mode(2)
		{
			m_size = inputData.size();
			m_dim = dimensionality;
			m_rootBbox.box = initBBox;
			init_vindRatio();
		}

		PartitioningKDTree(const int dimensionality, const std::vector<ElementType>& inputData) :
			m_ratiodata(inputData), m_root(NULL), m_mode(2)
		{
			m_size = inputData.size();
			m_dim = dimensionality;
			init_vindRatio();
		}

		void inputData(const std::vector<ElementType>& inputData) {
			m_ratiodata = inputData;
			m_size = inputData.size();
			init_vindRatio();
		}

		void inputData(const std::vector<std::vector<ElementType>>& inputData) {
			m_pointdata = inputData;
			m_size = inputData.size();
			init_vindPoint();
		}

		void setInitBox(const std::vector<std::vector<ElementType>>& initBBox) {
			m_rootBbox.box = initBBox;
		}

		//Printout the subspaces
		void regionShow()
		{
			for (auto i = 0; i < m_regions.size(); ++i)
			{
				for (auto j = 0; j < m_dim; ++j)
				{
					std::cout << "(" << m_regions[i].box[j].first << " , " << m_regions[i].box[j].second << ") ";
				}
				std::cout << std::endl << std::endl;
			}
			std::cout << std::endl;
		}
		/** Standard destructor */
		~PartitioningKDTree() { }

		/** Frees the previously-built index. Automatically called within buildIndex(). */
		void freeIndex()
		{
			m_pool.free_all();
			m_root = NULL;
			m_regions.clear();
		}

		/**
		* Builds the index
		*/
		void buildIndex()
		{
			freeIndex();
			if (m_mode == 1) // randomly constr
			{
				init_vindPoint();
				m_root = divideTree(0, m_size, m_rootBbox);   // construct the tree
			}
			else
			{
				init_vindRatio();
				m_root = ratioDivideTree(0, m_size, m_rootBbox);
			}
		}

		/** Returns number of leaf nodes  */
		size_t size() const {
			if (m_mode == 1) return m_size + 1;
			else if (m_mode == 2) 	return m_size;
		}

		/** Returns the length of each point in the dataset */
		size_t veclen() const {
			return m_dim;
		}

		/**
		* Computes the inde memory usage
		* Returns: memory used by the index
		*/
		size_t usedMemory() const
		{
			return m_pool.usedMemory + m_pool.wastedMemory + m_pointdata.size() * sizeof(IndexType);  // pool memory and vind array memory
		}

		size_t get_regionIdx(const std::vector<ElementType> & p) const {
			return enqury(p, m_root);
		}

		std::vector<BoundingBox>& get_regions() {
			return m_regions;
		}

		const BoundingBox& get_rootBox() {
			return m_rootBbox;
		}
		int smallestBox() { return m_sbox; }
		int largestBox() { return m_lbox; }
		const std::vector<std::vector<ElementType>>& get_box(int idx) const {
			return m_regions[idx].box;
		}
		double getBoxVolume(int idx) {
			return m_regions[idx].volume;
		}
		size_t get_depth(int idx) {
			return m_regions[idx].depth;
		}
		int split_region(int idx, int dim) {
			NodePtr node = nullptr;
			leafNode(idx, m_root, node);
			if (node == nullptr) return -1;
			NodePtr node1 = m_pool.allocate<Node>();
			NodePtr node2 = m_pool.allocate<Node>();
			node1->depth = node->depth + 1;
			node2->depth = node->depth + 1;
			node1->parent = node;
			node2->parent = node;
			node1->child1 = node1->child2 = NULL;
			node2->child1 = node2->child2 = NULL;
			node->child1 = node1;
			node->child2 = node2;
			//node->sub.divfeat = node->depth % m_dim;
			node->sub.divfeat = dim;
			node->sub.low = m_regions[idx].box[node->sub.divfeat].first;
			node->sub.high = m_regions[idx].box[node->sub.divfeat].second;
			node->sub.pivot = (node->sub.low + node->sub.high) / 2;
			node1->lr.idx_region = idx;
			node2->lr.idx_region = m_regions.size();
			m_regions[idx].volume /= 2;
			m_regions[idx].depth++;
			m_regions.push_back(m_regions[idx]);
			m_regions[idx].box[node->sub.divfeat].second = node->sub.pivot;
			m_regions.back().box[node->sub.divfeat].first = node->sub.pivot;
			m_size++;
			return node2->lr.idx_region;
		}

		void unions_at_depth(int depth, std::vector<std::vector<size_t>> & region_unions) const {
			if (!region_unions.empty()) region_unions.clear();
			find_unions_at_depth(depth, m_root, region_unions);
		}

		void find_neighbor(int idx, std::list<int> & neighbors) const {
			if (!neighbors.empty()) neighbors.clear();
			neighbor_check(idx, m_root, neighbors);
		}

		bool check_adjacency(int idx1, int idx2) const {
			bool result = true;
			const auto& box1 = m_regions[idx1].box;
			const auto& box2 = m_regions[idx2].box;
			for (size_t j = 0; j < m_dim; ++j) {
				if (box1[j].second < box2[j].first || box2[j].second < box1[j].first) {
					result = false;
					break;
				}
			}
			return result;
		}


	private:
		/** Make sure the auxiliary list \a vind has the same size than the current dataset, and re-generate if size has changed. */
		void init_vindPoint()
		{
			// Create a permutable array of indices to the input vectors.
			m_size = m_pointdata.size();
			if (m_vind.size() != m_size) m_vind.resize(m_size);
			size_t k = 0;
			for (auto& i : m_vind) i = k++;
		}

		/** Make sure the auxiliary list \a vind has the same size than the current ratiodata, and re-generate if size has changed. */
		void init_vindRatio()
		{
			// Create a permutable array of indices to the input vectors.
			m_size = m_ratiodata.size();
			if (m_vind.size() != m_size) m_vind.resize(m_size);
			size_t k = 0;
			for (auto& i : m_vind) i = k++;
		}

		/// Helper accessor to the dataset points:
		inline ElementType dataset_get(size_t idx, int component) const {
			return m_pointdata[idx][component];
		}

		/// Helper accessor to the ratiodata:
		inline ElementType ratiodata_get(size_t idx) const {
			return m_ratiodata[idx];
		}


		/**
		* Create a tree node that subdivides the list of vecs from vind[first]
		* to vind[last].  The routine is called recursively on each sublist.
		*
		* @param left index of the first vector
		* @param right index of the last vector
		*/
		NodePtr divideTree(const IndexType left, const IndexType right, BoundingBox & bbox, int depth = 0)
		{
			NodePtr node = m_pool.allocate<Node>(); // allocate memory

			/*a leaf node,create a sub-region. */
			if ((right - left) <= 0) {
				node->child1 = node->child2 = NULL;    /* Mark as leaf node. */
				node->lr.idx_region = m_regions.size();
				node->depth = depth;
				m_regions.push_back(bbox);
				boxRatio(m_regions.back(), m_regions.size() - 1);
			}
			else {
				IndexType idx;
				int cutfeat;
				ElementType cutval;
				middleSplit_(&m_vind[0] + left, right - left, idx, cutfeat, cutval, bbox, depth);

				node->sub.idx_sample = m_vind[left + idx];
				node->sub.divfeat = cutfeat;
				node->sub.low = bbox.box[cutfeat][0];
				node->sub.high = bbox.box[cutfeat][1];
				node->depth = depth;
				BoundingBox left_bbox(bbox);
				left_bbox.box[cutfeat][1] = cutval;
				//node->child1 = divideTree(left, left + idx, left_bbox, depth + 1);
				NodePtr temp = divideTree(left, left + idx, left_bbox, depth + 1);
				node->child1 = temp;
				temp->parent = node;

				BoundingBox right_bbox(bbox);
				right_bbox.box[cutfeat][0] = cutval;
				//node->child2 = divideTree(left + idx + 1, right, right_bbox, depth + 1);
				temp = divideTree(left + idx + 1, right, right_bbox, depth + 1);
				node->child2 = temp;
				temp->parent = node;

				node->sub.pivot = cutval;
			}
			return node;
		}


		NodePtr ratioDivideTree(const IndexType left, const IndexType right, BoundingBox & bbox, int depth = 0)
		{
			NodePtr node = m_pool.allocate<Node>(); // allocate memory
			if ((right - left) <= 1)
			{
				node->child1 = node->child2 = NULL;    /* Mark as leaf node. */
				node->lr.idx_region = m_regions.size();
				node->depth = depth;
				m_regions.push_back(bbox);                //�����ά����������
				boxRatio(m_regions.back(), m_regions.size() - 1);//region.back():����region����ĩβԪ�ص�����		
			}
			else {
				IndexType idx;
				int cutfeat;
				ElementType cutval;
				midSplit(&m_vind[0] + left, right - left, idx, cutfeat, cutval, bbox, depth);

				node->sub.idx_sample = m_vind[idx];//????
				node->sub.divfeat = cutfeat;
				node->sub.low = bbox.box[cutfeat][0];
				node->sub.high = bbox.box[cutfeat][1];
				node->depth = depth;

				BoundingBox left_bbox(bbox);
				left_bbox.box[cutfeat][1] = cutval;
				left_bbox.depth = depth + 1;
				NodePtr temp = ratioDivideTree(left, idx, left_bbox, depth + 1);
				node->child1 = temp;
				temp->parent = node;
				//node->child1 = ratioDivideTree(left, idx, left_bbox, depth + 1);

				BoundingBox right_bbox(bbox);
				right_bbox.box[cutfeat][0] = cutval;
				right_bbox.depth = depth + 1;
				temp = ratioDivideTree(idx, right, right_bbox, depth + 1);
				node->child2 = temp;
				temp->parent = node;
				//node->child2 = ratioDivideTree(idx, right, right_bbox, depth + 1);
				node->sub.pivot = cutval;
			}
			return node;
		}


		void computeMinMax(IndexType * ind, IndexType count, int element, ElementType & min_elem, ElementType & max_elem)
		{
			min_elem = dataset_get(ind[0], element);
			max_elem = dataset_get(ind[0], element);
			for (IndexType i = 1; i < count; ++i) {
				ElementType val = dataset_get(ind[i], element);
				if (val < min_elem) min_elem = val;
				if (val > max_elem) max_elem = val;
			}
		}

		void middleSplit_(IndexType * ind, IndexType count, IndexType & index, int& cutfeat, ElementType & cutval, const BoundingBox & bbox, int depth)
		{

			cutfeat = depth % m_dim;
			// for a balanced kd-tree, split in the median value
			std::vector<IndexType> cur_idx(count);
			for (IndexType i = 0; i < count; ++i) {
				cur_idx[i] = ind[i];
			}
			std::nth_element(cur_idx.begin(), cur_idx.begin() + cur_idx.size() / 2, cur_idx.end(), [this, &cutfeat](const IndexType a, const IndexType b) {
				return this->dataset_get(a, cutfeat) < this->dataset_get(b, cutfeat);
			});
			ElementType split_val = dataset_get(cur_idx[cur_idx.size() / 2], cutfeat);
			//.....

			ElementType min_elem, max_elem;
			computeMinMax(ind, count, cutfeat, min_elem, max_elem);

			if (split_val < min_elem) cutval = min_elem;
			else if (split_val > max_elem) cutval = max_elem;
			else cutval = split_val;

			IndexType lim1, lim2;
			planeSplit(ind, count, cutfeat, cutval, lim1, lim2);

			if (lim1 > count / 2) index = lim1;
			else if (lim2 < count / 2) index = lim2;
			else index = count / 2;
		}

		void midSplit(IndexType * ind, IndexType count, IndexType & index, int& cutfeat, ElementType & cutval, const BoundingBox & bbox, int depth)
		{
			double sum1 = 0.0;
			double sum2 = 0.0;
			cutfeat = depth % m_dim;
			//cutfeat = rand() % m_dim;
			std::vector<IndexType> cur_idx(count);
			for (IndexType i = 0; i < count; ++i)
			{
				cur_idx[i] = ind[i];
			}

			index = cur_idx[cur_idx.size() / 2];

			for (auto& i : cur_idx)
				sum1 += m_ratiodata[i];

			for (auto j = 0; j < cur_idx.size() / 2; ++j)
			{
				sum2 += m_ratiodata[cur_idx[j]];
			}

			cutval = bbox.box[cutfeat][0] + (bbox.box[cutfeat][1] - bbox.box[cutfeat][0]) * (sum2 / sum1);
		}
		/**
		*  Subdivide the list of points by a plane perpendicular on axe corresponding
		*  to the 'cutfeat' dimension at 'cutval' position.
		*
		*  On return:
		*  dataset[ind[0..lim1-1]][cutfeat]<cutval
		*  dataset[ind[lim1..lim2-1]][cutfeat]==cutval
		*  dataset[ind[lim2..count]][cutfeat]>cutval
		*/
		void planeSplit(IndexType * ind, const IndexType count, int cutfeat, ElementType cutval, IndexType & lim1, IndexType & lim2)
		{
			/* Move vector indices for left subtree to front of list. */
			IndexType left = 0;
			IndexType right = count - 1;
			for (;;) {
				while (left <= right && dataset_get(ind[left], cutfeat) < cutval) ++left;
				while (right && left <= right && dataset_get(ind[right], cutfeat) >= cutval) --right;
				if (left > right || !right) break;  // "!right" was added to support unsigned Index types
				std::swap(ind[left], ind[right]);
				++left;
				--right;
			}
			/* If either list is empty, it means that all remaining features
			* are identical. Split in the middle to maintain a balanced tree.
			*/
			lim1 = left;
			right = count - 1;
			for (;;) {
				while (left <= right && dataset_get(ind[left], cutfeat) <= cutval) ++left;
				while (right && left <= right && dataset_get(ind[right], cutfeat) > cutval) --right;
				if (left > right || !right) break;  // "!right" was added to support unsigned Index types
				std::swap(ind[left], ind[right]);
				++left;
				--right;
			}
			lim2 = left;
		}

		size_t enqury(const std::vector<ElementType> & p, NodePtr node) const {
			if (node->child1 == NULL && node->child2 == NULL) {
				return node->lr.idx_region;
			}
			if (m_mode == 1) {
				if (p[node->sub.divfeat] < dataset_get(node->sub.idx_sample, node->sub.divfeat)) {
					return enqury(p, node->child1);
				}
				else {
					return enqury(p, node->child2);
				}
			}
			else if (m_mode == 2) {
				if (p[node->sub.divfeat] < node->sub.pivot) {
					return enqury(p, node->child1);
				}
				else {
					return enqury(p, node->child2);
				}
			}
			return 0;
		}
		void leafParent(IndexType idx_region, NodePtr node, NodePtr parent, NodePtr & result) {
			if (node->child1 == NULL && node->child2 == NULL) {
				if (node->lr.idx_region == idx_region) {
					if (node != m_root) result = parent;
					else {
						result = m_root;
					}
				}
				return;
			}
			if (node->child1 != NULL && result == NULL)  leafParent(idx_region, node->child1, node, result);
			if (node->child2 != NULL && result == NULL)  leafParent(idx_region, node->child2, node, result);
		}

		void boxRatio(BoundingBox & it, unsigned idx) {
			it.rat = 1;
			for (int i = 0; i < m_dim; ++i) {
				it.rat *= (it.box[i][1] - it.box[i][0]) / (m_rootBbox.box[i][1] - m_rootBbox.box[i][0]);
			}
			if (it.rat > m_lrat) {
				m_lrat = it.rat;
				m_lbox = idx;
			}
			if (it.rat < m_srat) {
				m_srat = it.rat;
				m_sbox = idx;
			}

			it.volume = 0;
			for (int i = 0; i < m_dim; ++i) {
				it.volume += (it.box[i][1] - it.box[i][0]) * (it.box[i][1] - it.box[i][0]);
			}
			it.volume = std::sqrt(it.volume);
		}

		void leafNode(IndexType idx_region, NodePtr node, NodePtr & leafnode) {
			if (node->child1 == NULL && node->child2 == NULL && node->lr.idx_region == idx_region) {
				leafnode = node;
				return;
			}
			if (node->child1 != NULL)  leafNode(idx_region, node->child1, leafnode);
			if (node->child2 != NULL)  leafNode(idx_region, node->child2, leafnode);
		}

		void get_leaf_regions(NodePtr node, std::vector<size_t> & idx_regions) const {
			if (node->child1 == NULL && node->child2 == NULL) {
				idx_regions.push_back(node->lr.idx_region);
				return;
			}
			if (node->child1 != NULL)
				get_leaf_regions(node->child1, idx_regions);
			if (node->child2 != NULL)
				get_leaf_regions(node->child2, idx_regions);
		}

		void find_unions_at_depth(int depth, NodePtr node, std::vector<std::vector<size_t>> & region_unions) const {
			if (node->depth == depth) {
				std::vector<size_t> idx_regions;
				get_leaf_regions(node, idx_regions);
				region_unions.push_back(std::move(idx_regions));
				return;
			}
			if (node->child1 != NULL)
				find_unions_at_depth(depth, node->child1, region_unions);
			if (node->child2 != NULL)
				find_unions_at_depth(depth, node->child2, region_unions);
		}

		void neighbor_check(int idx, NodePtr node, std::list<int> & neighbors) const {
			if (node->child1 == NULL && node->child2 == NULL && idx != node->lr.idx_region) {
				neighbors.emplace_back(node->lr.idx_region);
				return;
			}
			if (node->child1 != NULL) {
				if (!(m_regions[idx].box[node->sub.divfeat][1] < node->sub.low || node->sub.pivot < m_regions[idx].box[node->sub.divfeat][0]))
					neighbor_check(idx, node->child1, neighbors);
			}
			if (node->child2 != NULL) {
				if (!(m_regions[idx].box[node->sub.divfeat][1] < node->sub.pivot || node->sub.high < m_regions[idx].box[node->sub.divfeat][0]))
					neighbor_check(idx, node->child2, neighbors);
			}
		}
	};
	/** @} */ // end of grouping
} // end of NS


#endif /* kdtree_space_HPP_ */

