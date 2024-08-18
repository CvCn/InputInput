local N, T = ...
local W, M, U, D, G, L = unpack(T)
local locale = GetLocale() or 'enUS'
T[6] = L[locale]
