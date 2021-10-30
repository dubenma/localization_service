// Uncomment theese defines for debugging
//#define ENABLE_PROFILING
//#define ENABLE_DEBUG_COUT
#include "functions.h"
#include <map>
#include <set>
#include <unordered_set>
#include <omp.h>
using namespace std;

constexpr float NEG_INFINITY = -std::numeric_limits<float>::infinity();

/// <summary>
/// Finds tentative correspondencies between image pair (query image <-> database image)
/// </summary>
/// <param name="descriptorsQ">descriptors of features in query image</param>
/// <param name="descriptorsDBs">descriptors of features in every db image</param>
/// <returns>Tentative correspondencies (based on mutually nearest neighbor)</returns>
vector<map<size_t, size_t>> get_tcs(
	const fmatrix& desc_q,
	const vector<fmatrix>& descs_db,
	cublasHandle_t& cublasHandle)
{
	const auto db_pictures_num = descs_db.size();
	// Nalezene tentativni korespondence
	vector<map<size_t, size_t>> tent_cors(db_pictures_num);
	
	vector<float*> descs_q_cuda, descs_db_cuda, results_cuda;
	float* cuda_mem_addr;
	size_t result_rows = desc_q.c, result_cols = descs_db[0].c;
	for (int i = 0; i < db_pictures_num; ++i) {
		// Alokace pro matici popisujici query snimek
		size_t alloc_bytes_num = mem_align(16, desc_q.elems() * sizeof(float));
		cudaMalloc(&cuda_mem_addr, alloc_bytes_num);
		cudaMemcpy(cuda_mem_addr, desc_q.data, desc_q.elems() * sizeof(float), cudaMemcpyHostToDevice);
		descs_q_cuda.push_back(cuda_mem_addr);

		// Alokace pro matici popisujici databazovy snimek
		alloc_bytes_num = mem_align(16, descs_db[i].elems() * sizeof(float));
		cudaMalloc(&cuda_mem_addr, alloc_bytes_num);
		cudaMemcpy(cuda_mem_addr, descs_db[i].data, descs_db[i].elems() * sizeof(float), cudaMemcpyHostToDevice);
		descs_db_cuda.push_back(cuda_mem_addr);

		// Alokace pro vyslednou matici
		cudaMalloc(&cuda_mem_addr, mem_align(16, result_rows * result_cols * sizeof(float)));
		results_cuda.push_back(cuda_mem_addr);
	}
	
	float alpha = 1.0f, beta = 0.0f;
	cublasStatus_t matmulResult = cublasSgemmBatched(cublasHandle,
		CUBLAS_OP_T,									// Deskriptor query snimku se vzdy transponuje
		CUBLAS_OP_N,									// Deskriptor db. snimku se netransponuje
		desc_q.c, descs_db[0].c, desc_q.r,				// Pocet radku v desc_q^T, sloupcu v desc_db a sloupcu v desc_q^T
		&alpha,											// alpha je vzdy 1
		const_cast<const float**>(&descs_q_cuda[0]),	// Ulozeni matic v pameti CUDA. Zarovnat na 16 bajtu kazde pole pro matici, ale ne pole poli!
		descs_db[0].r,									// leading dimension v ulozenem poli matice
		const_cast<const float**>(&descs_db_cuda[0]),	// Ulozeni matic v pameti CUDA. Zarovnat na 16 bajtu kazde pole pro matici, ale ne pole poli!
		descs_db[0].r,									// leading dimension v ulozenem poli matice
		&beta,											// beta je vzdy 0
		&results_cuda[0],								// Mista pro ulozeni vyslednych matic v pameti CUDA. Zarovnat na 16 bajtu kazde pole pro matici, ale ne pole poli!
		desc_q.c,										// leading dimension v ulozenem poli matice
		db_pictures_num);

	// Zkopirovat vysledek z cudy do pameti
	vector<float*> results;
	for (int i = 0; i < db_pictures_num; ++i) {
		results.push_back(new float[result_rows * result_cols]);
		cudaMemcpy(results[i] , cuda_mem_addr, desc_q.elems() * sizeof(float), cudaMemcpyDeviceToHost);
	}


	// Free pameti CUDA
	for (int i = 0; i < db_pictures_num; ++i) {
		cudaFree(descs_q_cuda[i]);
		cudaFree(descs_db_cuda[i]);
		cudaFree(results_cuda[i]);
	}

	//const int nr_rows_A = descriptorsA_norm.rows(),
	//	nr_cols_A = descriptorsA_norm.cols();
	//
	//matrix_vector dists_all;
	//if (descriptorsB_norms.size() > 1) { // Batch processing of many matrices
	//	// Prepare matrix info for batch gemm processing.
	//	// Gemm does matrix multiplication: (C := alpha*op(A)*op(B) + beta*C). For standard multiplication set alpha to 1 and beta to 0.
	//	vector<mkl_dim> Ms(descriptorsDBs.size(), descriptorsA_norm.cols()) // row dimension of transposed matrices descriptorsA
	//		, Ns(descriptorsDBs.size(), descriptorsB_norms[0].cols()) // row dimensions of matrices descriptorsDBs
	//		, Ks(descriptorsDBs.size(), descriptorsB_norms[0].rows()) // comumn dimensions of transposed matrices descriptorsA
	//		, ldas(descriptorsDBs.size(), descriptorsB_norms[0].rows()) // leading dimension of transposed descriptorsA_norm
	//		, ldbs(descriptorsDBs.size(), descriptorsB_norms[0].rows()) // leading dimension of descriptorsDBs
	//		, ldcs(descriptorsDBs.size(), descriptorsA_norm.cols()); // leading dimension of result (similarity matrix)
	//	vector<float> alphas(descriptorsDBs.size(), 1.0f), // parameter alpha for gemm operation (ones) 
	//		betas(descriptorsDBs.size(), 0.0f);  // parameter beta for gemm operation (zeros)
	//	vector<char> transas(descriptorsDBs.size(), 'T'), transbs(descriptorsDBs.size(), 'N'); // transposing - always transpose first matrix, never transpose the second.
	//	const mkl_dim group_count = std::min(descriptorsB_norms.size(), (size_t)8); // Let's divide the matrices to 8 groups for batch processing.
	//	vector<mkl_dim> group_sizes(group_count, 0); // How many matrices in each group.
	//	// Divide matrices into groups!
	//	for (int i = 0; i < group_count; ++i) {
	//		group_sizes[i] = descriptorsB_norms.size() / group_count;
	//	}
	//	group_sizes[group_count - 1] = descriptorsB_norms.size() - (descriptorsB_norms.size() / group_count) * (group_count - 1);
	//
	//	// Mapping matrices into raw pointers for MKL function sgemm_batch
	//	vector<float*> a_array, b_array;
	//	for (int i = 0; i < descriptorsB_norms.size(); ++i) {
	//		b_array.push_back(const_cast<float*>(descriptorsB_norms[i].data()));
	//		dists_all.push_back(MatrixXf(descriptorsA_norm.cols(), descriptorsB_norms[i].cols()));
	//		a_array.push_back(const_cast<float*>(descriptorsA_norm.data()));
	//	}
	//	vector<float*> dists_all_ptrs;
	//	for (int i = 0; i < descriptorsB_norms.size(); ++i) {
	//		dists_all_ptrs.push_back(const_cast<float*>(dists_all[i].data()));
	//	}
	//
	//	// batch matrix multiplication
	//	sgemm_batch(&transas.front(), &transbs.front(), &Ms.front(), &Ns.front(), &Ks.front(), &alphas.front(), (const float**)&a_array[0],
	//		&ldas.front(), (const float**)&b_array[0], &ldbs.front(), &betas.front(), &dists_all_ptrs[0], &ldcs.front(), (const mkl_dim*)&group_count, (const mkl_dim*)&group_sizes[0]);
	//}
	//else { // Only 1 matrix - no batch processing!
	//	dists_all.push_back(MatrixXf(descriptorsA_norm.cols(), descriptorsB_norms[0].cols()));
	//	// Parameters of matrices
	//	const mkl_dim M = descriptorsA_norm.cols()
	//		, N = descriptorsB_norms[0].cols()
	//		, K = descriptorsB_norms[0].rows()
	//		, lda = descriptorsB_norms[0].rows()
	//		, ldb = descriptorsB_norms[0].rows()
	//		, ldc = descriptorsA_norm.cols();
	//	const float alpha = 1.0, beta = 0.0;
	//	sgemm("T", "N", &M, &N, &K, &alpha, descriptorsA_norm.data(), &lda, descriptorsB_norms[0].data(), &ldb, &beta, const_cast<float*>(dists_all[0].data()), &ldc);
	//}

	// We have computed similarity matrix between features. Let's extract  tentative correspondencies using mutually nearest neighbor method.
	// It will run in parallel for if the similarity matrix is big enough (5000000 numbers or more)
	//#pragma omp parallel for if (dists_all[0].size() > 5000000)
	//for (size_t i = 0; i < descriptorsDBs.size(); ++i) {
	//	map<size_t, size_t> loc_tent_cors; // Tentative correspondencies for this image pair
	//	vector<pair<Index, float>> max_idx_val_for_cols; // Max row index and value for every column (= most similar feature)
	//	vector<float> max_val_for_rows(dists_all[i].rows(), NEG_INFINITY); // Max value in every row (the bigger value, the more similar feature)
	//	max_idx_val_for_cols.resize(dists_all[i].cols());
	//	const float* iter = dists_all[i].data();
	//
	//	// Find maxima for every row and col. If the maxima match, we've found a tentative correspondence between particular row and col
	//	// Max 1 correspondence per row/col. Similarity matrix has shape n^n, so max n TC could be found.
	//	for (Index c = 0; c < dists_all[i].cols(); ++c) {
	//		float max_in_col = NEG_INFINITY;
	//		Index max_idx_in_col;
	//		for (Index r = 0; r < dists_all[i].rows(); ++r, ++iter) {
	//			if (*iter > max_in_col) {
	//				max_in_col = *iter;
	//				max_idx_in_col = r;
	//			}
	//			max_val_for_rows[r] = std::max(max_val_for_rows[r], *iter);
	//		}
	//		max_idx_val_for_cols[c] = { max_idx_in_col, max_in_col };
	//	}
	//	Index c = 0;
	//	for (const auto& min_index_val : max_idx_val_for_cols) {
	//		if (max_val_for_rows[min_index_val.first] == min_index_val.second) // We've found a TC!
	//			if (loc_tent_cors.find(min_index_val.first + 1) == loc_tent_cors.end()) {
	//				loc_tent_cors[min_index_val.first + 1] = c + 1;
	//			}
	//			else {
	//				// Only 1 correspondence per column/row. Rewrite it!
	//				loc_tent_cors[min_index_val.first + 1] = std::min(loc_tent_cors[(size_t)min_index_val.first + 1], (size_t)c + 1);
	//			}
	//		++c;
	//	}
	//	// Move found correspondencies to result list
	//	tent_cors[i] = std::move(loc_tent_cors);
	//}

	// Free vektoru results
	return tent_cors;
}