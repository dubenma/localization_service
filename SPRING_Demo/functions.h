#pragma once
#include "base.h"

/// <summary>
/// Finds tentative correspondencies between image pair (query image <-> database image)
/// </summary>
/// <param name="descriptorsQ">descriptors of features in query image</param>
/// <param name="descriptorsDBs">descriptors of features in every db image</param>
/// <returns>Tentative correspondencies (based on mutually nearest neighbor)</returns>
std::vector<std::map<size_t, size_t>> get_tcs(
	const fmatrix& descriptorQ,
	const std::vector<fmatrix>& descriptorsDBs,
	cublasHandle_t& cublasHandle);

inline size_t mem_align(size_t align_const, size_t bytes_num) {
    size_t rest = bytes_num % align_const;

    if (bytes_num < align_const)
        return align_const;
    else if (rest > 0)
        return bytes_num + 16 - rest;
    else
        return bytes_num;
}