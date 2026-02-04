package com.fenizo.tringo_owner.tringo_owner

data class AdItem(
    val id: String? = null,
    val tamilName: String? = null,
    val englishName: String? = null,
    val addressTa: String? = null,
    val addressEn: String? = null,
    val city: String? = null,
    val state: String? = null,
    val country: String? = null,
    val distanceLabel: String? = null,
    val rating: Double? = null,
    val ratingCount: Int? = null,
    val openLabel: String? = null,
    val isTrusted: Boolean? = null,
    val primaryImageUrl: String? = null,
    val primaryPhone: String? = null
)
