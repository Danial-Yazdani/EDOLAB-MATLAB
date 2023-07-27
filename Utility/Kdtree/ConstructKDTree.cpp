#include "kdtree_space.h"
#include "mex.h"
#include "matrix.h"

//int main() {
//	using KDTree = KDTreeSpace::PartitioningKDTree<double>;
//	KDTree m_space(2);
//	m_space.set_dim(2);
//	std::vector<std::vector<double>> boundary;
//	std::vector<double> x1{ 0.,1.};
//	std::vector<double> x2{ 1.,2. };
//	boundary.emplace_back(x1);
//	boundary.emplace_back(x2);
//	m_space.setInitBox(boundary);
//	int num = 10;
//	m_space.inputData(std::vector<double>(num,1./ num));
//	m_space.buildIndex();
//	auto regions = m_space.get_regions()[0].box;
//	std::list<int> neighbors;
//	m_space.find_neighbor(1,neighbors);
//	return 0;
//}

static void ConstructKDtree(double x1[],double x2[],int num,int dim,double y[]){
	//x1是每个子空间的边界，x2是子空间的邻接关系矩阵
	using KDTree=KDTreeSpace::PartitioningKDTree<double>;
	KDTree m_space(2);
	m_space.set_dim(dim);
	std::vector<std::vector<double>> boundary;
	for (int m = 0; m < dim; ++m) {
		std::vector<double> temp;
		for (int n = 0; n < 2; ++n) {
			temp.push_back(y[m+n*dim]);
		}
		boundary.emplace_back(temp);
	}
	m_space.setInitBox(boundary);
	m_space.inputData(std::vector<double>(num,1./ num));
	m_space.buildIndex();
	auto regions = m_space.get_regions();
	//得到每个子空间的范围
	for (int i = 0; i < num; i++) {
		for (int j = 0; j < dim; j++) {
			for (int k = 0; k < 2; k++) {
				x1[i * dim + j + k * num * dim] = regions[i].box[j][k];
			}
		}
	}
	//得到每个子空间的邻接矩阵
	for (int i = 0; i < num; i++) {
		std::list<int> neighbors;
		m_space.find_neighbor(i, neighbors);
		for (int j = 0; j < num; j++) {
			if (i == j)
				x2[i*num+j] = 1;
			else {
				if(std::find(neighbors.begin(),neighbors.end(),j)==neighbors.end())
					x2[i * num + j] = 0;
				else
					x2[i * num + j] = 1;
			}
		}
	}
	return;
}

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray *prhs[]) {
	double *x1,*x2,*y;
	int  mrows, ncols;
	int n = mxGetNumberOfElements(prhs[0]);
	//int dim = mxGetNumberOfDimensions(prhs[1]);
	if (nrhs != 2)
		mexErrMsgTxt("two input required.");
	else if (nlhs > 2)
		mexErrMsgTxt("Too many output arguments");
	if (n>1)
		mexErrMsgTxt("Input must be a int scalar.");
	double* num = mxGetPr(prhs[0]);//个数
	int m = *num;
	if(m<=0)
		mexErrMsgTxt("The first input must be more than 0.");
	mrows = mxGetM(prhs[1]);//取值范围
	ncols = mxGetN(prhs[1]);
	if(ncols!=2)
		mexErrMsgTxt("The columns of the second input must be 2.");
	/*if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || !(mrows == 1 && ncols == 1))
		mexErrMsgTxt("Input must be a noncomplex scalar double.");*/
	plhs[0] = mxCreateDoubleMatrix(m * mrows, ncols, mxREAL);
	plhs[1] = mxCreateDoubleMatrix(m, m, mxREAL);
	y = mxGetPr(prhs[1]);
	x1 = mxGetPr(plhs[0]);
	x2 = mxGetPr(plhs[1]);
	ConstructKDtree(x1,x2,m,mrows,y);
}