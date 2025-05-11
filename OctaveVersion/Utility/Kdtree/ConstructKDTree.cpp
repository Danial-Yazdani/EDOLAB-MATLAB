#include "kdtree_space.h"
#include "mex.h"
#include "matrix.h"

static void ConstructKDtree(double x1[], double x2[], int num, int dim, double y[], double weights[]) {
    using KDTree = KDTreeSpace::PartitioningKDTree<double>;
    KDTree m_space(2);
    m_space.set_dim(dim);

    // Set partitioning weights (volumetric proportions for each subspace)
    std::vector<double> weight_vector(weights, weights + num);  // Convert weights array to vector
    m_space.inputData(weight_vector);  // Pass the weights to the KDTree builder

    std::vector<std::vector<double>> boundary;
    for (int m = 0; m < dim; ++m) {
        std::vector<double> temp;
        for (int n = 0; n < 2; ++n) {
            temp.push_back(y[m + n * dim]);
        }
        boundary.emplace_back(temp);
    }
    m_space.setInitBox(boundary);  // Set initial boundaries (range of each subspace)
    m_space.buildIndex();  // Build the KDTree index using the provided data
    auto regions = m_space.get_regions();  // Get the partitioned subspaces

    // Retrieve the boundaries of each subspace
    for (int i = 0; i < num; i++) {
        for (int j = 0; j < dim; j++) {
            for (int k = 0; k < 2; k++) {
                x1[i * dim + j + k * num * dim] = regions[i].box[j][k];
            }
        }
    }

    // Retrieve the adjacency matrix (whether two subspaces are adjacent)
    for (int i = 0; i < num; i++) {
        std::list<int> neighbors;
        m_space.find_neighbor(i, neighbors);  // Find neighboring regions
        for (int j = 0; j < num; j++) {
            if (i == j)
                x2[i * num + j] = 1;  // A subspace is always adjacent to itself
            else {
                if (std::find(neighbors.begin(), neighbors.end(), j) == neighbors.end())
                    x2[i * num + j] = 0;  // No adjacency
                else
                    x2[i * num + j] = 1;  // Adjacent subspaces
            }
        }
    }
    return;
}


void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray *prhs[]) {
    double *x1, *x2, *y, *weights;
    int mrows, ncols;
    int n = mxGetNumberOfElements(prhs[0]);

    // Ensure that there are three inputs
    if (nrhs != 3)
        mexErrMsgTxt("Three inputs required.");
    else if (nlhs > 2)
        mexErrMsgTxt("Too many output arguments");

    if (n > 1)
        mexErrMsgTxt("Input must be an int scalar.");
    double* num = mxGetPr(prhs[0]); // Number of subspaces
    int m = *num;
    if (m <= 0)
        mexErrMsgTxt("The first input must be more than 0.");

    // Handle second input: y array (boundaries of each subspace)
    mrows = mxGetM(prhs[1]);
    ncols = mxGetN(prhs[1]);
    if (ncols != 2)
        mexErrMsgTxt("The columns of the second input must be 2.");
    y = mxGetPr(prhs[1]);

    // Handle third input: weights array (volumetric proportions for each subspace)
    if (!mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || mxGetNumberOfElements(prhs[2]) != m)
        mexErrMsgTxt("The third input must be a double array of length m.");
    weights = mxGetPr(prhs[2]);

    // Create output matrices
    plhs[0] = mxCreateDoubleMatrix(m * mrows, ncols, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(m, m, mxREAL);

    // Get pointers to output matrices
    x1 = mxGetPr(plhs[0]);
    x2 = mxGetPr(plhs[1]);

    // Call ConstructKDtree function with new weights input
    ConstructKDtree(x1, x2, m, mrows, y, weights);
}