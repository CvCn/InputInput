local N, T = ...
local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))
local GetLocale = API.GetLocale
local locale = GetLocale() or 'enUS'
T[6] = L[locale]
