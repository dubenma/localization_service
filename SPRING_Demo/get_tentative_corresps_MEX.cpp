//#define ENABLE_DEBUG_COUT
//#define ENABLE_PROFILING
#include <mex.h>
#include <string>
#include <list>
#include "base.h"
#include "functions.h"

using namespace std;

/// <summary>
/// Main function of MEX library.
/// Finds tentative correspondencies
/// </summary>
/// <param name="nlhs">number of output parameters</param>
/// <param name="plhs">output parameters</param>
/// <param name="nrhs">number of input parameters</param>
/// <param name="prhs">input parameters</param>
void mexFunction(int nlhs, mxArray* plhs[],
    int nrhs, const mxArray* prhs[])
{
    if (nrhs != 2)
        mexErrMsgTxt("Invalid number of input arguments - 2 required.");

    if (nlhs != 1)
        mexErrMsgTxt("1 output argument required");
    
    fmatrix desc1_mat(mxGetM(prhs[0]), mxGetN(prhs[0]), (float*)mxGetPr(prhs[0]));

    const auto dims = mxGetDimensions(prhs[1]);
    const mwSize num_desc2 = std::max(dims[0], dims[1]);
    
    // Descriptors of db images (cell with 2d arrays)
    const mxArray* descs2_cell = prhs[1];
    vector<fmatrix> descs2; // descriptors data mapped to matrices

    mxArray* cellElement;
    for (mwIndex i = 0; i < num_desc2; ++i) {
        cellElement = mxGetCell(descs2_cell, i);
        int rws = mxGetM(cellElement);
        int cls = mxGetN(cellElement);
        descs2.push_back(fmatrix(rws, cls, (float*)mxGetPr(cellElement)));
    }

    // Krok 0 : inicializace cuBLAS
    cudaError_t cudaStat;
    cublasStatus_t stat;
    cublasHandle_t cublasHandle;
    stat = cublasCreate(&cublasHandle);
    if (stat != CUBLAS_STATUS_SUCCESS) {
        cerr << "Nepodarilo se inicializovat cuBLAS" << endl;
        return;
    }

    // Tentative correspondencies for each image pair (query <-> db)
    vector<map<size_t, size_t>> matches = get_tcs(desc1_mat, descs2, cublasHandle);

    // Send correspondencies into Matlab's memory
    auto cell_array_ptr = mxCreateCellMatrix(num_desc2, 1);
    for (mwIndex i = 0; i < num_desc2; ++i) {
        auto arr_corresps = mxCreateNumericMatrix(2, matches[i].size(), mxINT32_CLASS, mxREAL);
        int* assign = (int*)mxGetPr(arr_corresps);
        size_t j = 0;
        for (const auto& match : matches[i]) {
            assign[j] = match.first;
            assign[j + 1] = match.second;
            j += 2;
        }
        mxSetCell(cell_array_ptr, i, arr_corresps);
    }
    plhs[0] = cell_array_ptr;
}