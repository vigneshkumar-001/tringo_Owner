
package com.feni.tringo.tringo_app

data class CallerLookupResponse(
    val isBusiness: Boolean?,
    val personName: String?,
    val businessName: String?,
    val rating: Double?,
    val openText: String?,
    val category: String?,
    val ads: List<AdItem> = emptyList()
)
