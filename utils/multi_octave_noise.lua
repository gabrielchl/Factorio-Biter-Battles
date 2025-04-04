local simplex_noise = require('utils.simplex_noise').d2

return {
    --- Accumulates values of multiple octaves (layers) of simplex noise at the specified position
    ---@param octaves [{amp: number, freq: number}]
    ---@param x number
    ---@param y number
    ---@param seed number
    ---@param offset number offset of the seed between each octave. Providing low value will result at interference near origin point
    ---@return number # of the range [-1; 1] * (sum of modules of all amplitudes)
    get = function(octaves, x, y, seed, offset)
        local noise = 0
        for _, octave in pairs(octaves) do
            noise = noise + simplex_noise(x * octave.freq, y * octave.freq, seed) * octave.amp
            seed = seed + offset
        end
        return noise
    end,

    --- Calculates noise value for given octaves, short circuits if further computations won't exceed `lower_bound` value
    ---
    --- This function expects octaves ordered by positive amplitudes in descending order
    ---@param octaves [{amp: number, freq: number}]
    ---@param amplitude_sum number # precalculated sum of amplitudes of all layers
    ---@param x number
    ---@param y number
    ---@param seed number
    ---@param offset number offset of the seed between each octave. Providing low value will result at interference near origin point
    ---@param lower_bound number
    ---@return number? # of the range [-1; 1] * (sum of all amplitudes), if value exceeds cutoff
    get_lower_bounded = function(octaves, amplitude_sum, x, y, seed, offset, lower_bound)
        local noise = 0.0
        local amplitude_left = amplitude_sum
        for _, octave in pairs(octaves) do
            noise = noise + simplex_noise(x * octave.freq, y * octave.freq, seed) * octave.amp
            amplitude_left = amplitude_left - octave.amp
            if noise + amplitude_left <= lower_bound then
                return nil
            end
            seed = seed + offset
        end
        return noise
    end,

    --- Calculates noise value for given octaves, short circuits if further computations reach or excide `upper_bound` value
    ---
    --- This function expects octaves ordered by positive amplitudes in descending order
    ---@param octaves [{amp: number, freq: number}]
    ---@param amplitude_sum number # precalculated sum of amplitudes of all layers
    ---@param x number
    ---@param y number
    ---@param seed number
    ---@param offset number offset of the seed between each octave. Providing low value will result at interference near origin point
    ---@param upper_bound number
    ---@return number? # of the range [-1; 1] * (sum of all amplitudes), if value below cutoff
    get_upper_bounded = function(octaves, amplitude_sum, x, y, seed, offset, upper_bound)
        local noise = 0.0
        local amplitude_left = amplitude_sum
        for _, octave in pairs(octaves) do
            noise = noise + simplex_noise(x * octave.freq, y * octave.freq, seed) * octave.amp
            amplitude_left = amplitude_left - octave.amp
            if noise - amplitude_left >= upper_bound then
                return nil
            end
            seed = seed + offset
        end
        return noise
    end,

    --- Calculates noise value for given octaves, short circuits if further computations give result inside specified bounds
    ---
    --- This function expects octaves ordered by positive amplitudes in descending order
    ---@param octaves [{amp: number, freq: number}]
    ---@param amplitude_sum number # precalculated sum of amplitudes of all layers
    ---@param x number
    ---@param y number
    ---@param seed number
    ---@param offset number offset of the seed between each octave. Providing low value will result at interference near origin point
    ---@param lb number lower bound
    ---@param ub number upper bound
    ---@return number? # of the range [-1; 1] * (sum of all amplitudes), if value is outside bounds
    get_outside_bounds = function(octaves, amplitude_sum, x, y, seed, offset, lb, ub)
        local noise = 0.0
        local amplitude_left = amplitude_sum
        for _, octave in pairs(octaves) do
            noise = noise + simplex_noise(x * octave.freq, y * octave.freq, seed) * octave.amp
            amplitude_left = amplitude_left - octave.amp
            if noise - amplitude_left >= lb and noise + amplitude_left <= ub then
                return nil
            end
            seed = seed + offset
        end
        return noise
    end,

    --- Calculates noise value for given octaves, short circuits if further computations give result outside (inclusive) specified bounds
    ---
    --- This function expects octaves ordered by positive amplitudes in descending order
    ---@param octaves [{amp: number, freq: number}]
    ---@param amplitude_sum number # precalculated sum of amplitudes of all layers
    ---@param x number
    ---@param y number
    ---@param seed number
    ---@param offset number offset of the seed between each octave. Providing low value will result at interference near origin point
    ---@param lb number lower bound
    ---@param ub number upper bound
    ---@return number? # of the range [-1; 1] * (sum of all amplitudes), if value is between bounds
    get_between_bounds = function(octaves, amplitude_sum, x, y, seed, offset, lb, ub)
        local noise = 0.0
        local amplitude_left = amplitude_sum
        for _, octave in pairs(octaves) do
            noise = noise + simplex_noise(x * octave.freq, y * octave.freq, seed) * octave.amp
            amplitude_left = amplitude_left - octave.amp

            if noise + amplitude_left <= lb or noise - amplitude_left >= ub then
                return nil
            end
            seed = seed + offset
        end
        return noise
    end,
}
