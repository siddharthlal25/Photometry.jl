module Background

using Statistics

export estimate_background,
       Mean,
       Median,
       Mode,
       sigma_clip,
       sigma_clip!


# Abstract types
"""
    Background.BackgroundEstimator

This abstract type embodies the possible background estimation algorithms for dispatch with [`estimate_background`](@ref).
"""
abstract type BackgroundEstimator end


"""
    estimate_background(::BackgroundEstimator, data; dims=:)

Perform 2D background estimation using the given estimator.

The value returned will be an two arrays corresponding to the estimated background, whose dimensionality will depend on the `dims` keyword and the estimator used.

If the background estimator has no parameters (like [`Mean`](@ref)), you can just specify the type without construction.

# See Also
[Background Estimators](@ref)
"""
estimate_background(::BackgroundEstimator, ::AbstractArray; dims = :)
estimate_background(T::Type{<:BackgroundEstimator}, d::AbstractArray; dims = :) = estimate_background(T(), d; dims = dims)

"""
    estimate_background(:BackgroundEstimator, data, box_size, kernel_size; dims=:)

Perform 2D background estimation using the given estimator using meshes and kernels.

This function will estimate backgrounds in meshes of size `box_size`, using a filter kernel of size `kernel_size`. These correspond to the dimension, so for 2D data you could specify (20,) or (20,20) as the box/kernel size, matching with dims=1 for the scalar variant.

If either size is an integer, the implicit shape will be square (eg. `box_size=4` is equivalent to `box_size=(4,4)`). Contrast this to a single dimension size, like `box_size=(4,)`.

If the background estimator has no parameters (like [`Mean`](@ref)), you can just specify the type without construction.

# See Also
[Background Estimators](@ref)
"""
estimate_background(::BackgroundEstimator, ::AbstractArray, ::Tuple, ::Tuple; dims = :) = error("Not implemented!")
estimate_background(T::Type{<:BackgroundEstimator}, d::AbstractArray, b::Tuple, k::Tuple; dims = :) = estimate_background(T(), d, b, k; dims = dims)
estimate_background(alg::BackgroundEstimator, data::AbstractArray, box_size::Integer, kernel_size; dims = :) = estimate_background(alg, data, (box_size, box_size), kernel_size; dims = dims)
estimate_background(alg::BackgroundEstimator, data::AbstractArray, box_size, kernel_size::Integer; dims = :) = estimate_background(alg, data, box_size, (kernel_size, kernel_size); dims = dims)


"""
    sigma_clip!(data, sigma_low, sigma_high; center=median, std=std)
    sigma_clip!(data, sigma; center=median, std=std)
In-place version of [`sigma_clip`](@ref)
!!! warning
    `sigma_clip!` mutates the element in place and mutation cannot lead to change in type.
    User should be careful about using the data-types. E.g.- `x = [1,2,3]`, calling `clamp!(x, 0.5, 0.5)`
    would lead to error because the value of 1 and 3 should have become `Float` from `Int`, but mutation of type is not
    permissible.
"""

function sigma_clip!(data::AbstractArray, sigma_low::Real, sigma_high::Real=sigma_low; center=median, std=std)
    mean = center(data)
    deviation = std(data)
    clamp!(data, mean - sigma_low * deviation, mean + sigma_high * deviation)
    return data
end

"""
    sigma_clip(data, sigma_low, sigma_high; center=median, std=std)
    sigma_clip(data, sigma; center=median, std=std)
This function returns sigma clipped values of the input `data`.
`sigma_high` and `sigma_low` are for un-symmetrical clipping, when `sigma_low = sigma_high` then they can be passed as `sigma`.
`center` and `std` are optional parameters which are functions for finding central element and standard deviation.
# Example
```jldoctest
julia> data = [1, 2, 3];
julia> sigma_clip(data, 1)
3-element Array{Float64,1}:
 1.0
 2.0
 3.0
julia> sigma_clip(data, 1, 1)
3-element Array{Float64,1}:
 1.0
 2.0
 3.0
```
"""
sigma_clip(data, rest...; kwargs...) = sigma_clip!(float(data), rest...; kwargs...)

# Estimators
include("stat_estimators.jl")

end # Background
