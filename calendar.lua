-- 公历农历转换
-- {{#Invoke:Calendar|solar_to_lunar|2020-04-23}} => 2020-04-01
-- {{#Invoke:Calendar|solar_to_lunar|2020-05-23}} => 2020-04-01L  (L表示闰月)
-- {{#Invoke:Calendar|lunar_to_solar|2020-04-01}} => 2020-04-23
-- {{#Invoke:Calendar|lunar_to_solar|2020-04-01L}} => 2020-05-23
-- {{#Invoke:Calendar|lunar_format|2020-04-01}} => 二零二零年四月初一
-- {{#Invoke:Calendar|lunar_format|2020-04-01Lleap}} => 二零二零年闰四月初一

local bit32 = require( 'bit32' )

local data = {
    [1900]={solar_start=0,lunar_start=30,lunar_code=19416},
    [1901]={solar_start=365,lunar_start=414,lunar_code=19168},
    [1902]={solar_start=730,lunar_start=768,lunar_code=42352},
    [1903]={solar_start=1095,lunar_start=1123,lunar_code=21717},
    [1904]={solar_start=1460,lunar_start=1506,lunar_code=53856},
    [1905]={solar_start=1826,lunar_start=1860,lunar_code=55632},
    [1906]={solar_start=2191,lunar_start=2215,lunar_code=91476},
    [1907]={solar_start=2556,lunar_start=2599,lunar_code=22176},
    [1908]={solar_start=2921,lunar_start=2953,lunar_code=39632},
    [1909]={solar_start=3287,lunar_start=3308,lunar_code=21970},
    [1910]={solar_start=3652,lunar_start=3692,lunar_code=19168},
    [1911]={solar_start=4017,lunar_start=4046,lunar_code=42422},
    [1912]={solar_start=4382,lunar_start=4430,lunar_code=42192},
    [1913]={solar_start=4748,lunar_start=4784,lunar_code=53840},
    [1914]={solar_start=5113,lunar_start=5138,lunar_code=119381},
    [1915]={solar_start=5478,lunar_start=5522,lunar_code=46400},
    [1916]={solar_start=5843,lunar_start=5876,lunar_code=54944},
    [1917]={solar_start=6209,lunar_start=6231,lunar_code=44450},
    [1918]={solar_start=6574,lunar_start=6615,lunar_code=38320},
    [1919]={solar_start=6939,lunar_start=6970,lunar_code=84343},
    [1920]={solar_start=7304,lunar_start=7354,lunar_code=18800},
    [1921]={solar_start=7670,lunar_start=7708,lunar_code=42160},
    [1922]={solar_start=8035,lunar_start=8062,lunar_code=46261},
    [1923]={solar_start=8400,lunar_start=8446,lunar_code=27216},
    [1924]={solar_start=8765,lunar_start=8800,lunar_code=27968},
    [1925]={solar_start=9131,lunar_start=9154,lunar_code=109396},
    [1926]={solar_start=9496,lunar_start=9539,lunar_code=11104},
    [1927]={solar_start=9861,lunar_start=9893,lunar_code=38256},
    [1928]={solar_start=10226,lunar_start=10248,lunar_code=21234},
    [1929]={solar_start=10592,lunar_start=10632,lunar_code=18800},
    [1930]={solar_start=10957,lunar_start=10986,lunar_code=25958},
    [1931]={solar_start=11322,lunar_start=11369,lunar_code=54432},
    [1932]={solar_start=11687,lunar_start=11723,lunar_code=59984},
    [1933]={solar_start=12053,lunar_start=12078,lunar_code=92821},
    [1934]={solar_start=12418,lunar_start=12462,lunar_code=23248},
    [1935]={solar_start=12783,lunar_start=12817,lunar_code=11104},
    [1936]={solar_start=13148,lunar_start=13171,lunar_code=100067},
    [1937]={solar_start=13514,lunar_start=13555,lunar_code=37600},
    [1938]={solar_start=13879,lunar_start=13909,lunar_code=116951},
    [1939]={solar_start=14244,lunar_start=14293,lunar_code=51536},
    [1940]={solar_start=14609,lunar_start=14647,lunar_code=54432},
    [1941]={solar_start=14975,lunar_start=15001,lunar_code=120998},
    [1942]={solar_start=15340,lunar_start=15385,lunar_code=46416},
    [1943]={solar_start=15705,lunar_start=15740,lunar_code=22176},
    [1944]={solar_start=16070,lunar_start=16094,lunar_code=107956},
    [1945]={solar_start=16436,lunar_start=16479,lunar_code=9680},
    [1946]={solar_start=16801,lunar_start=16833,lunar_code=37584},
    [1947]={solar_start=17166,lunar_start=17187,lunar_code=53938},
    [1948]={solar_start=17531,lunar_start=17571,lunar_code=43344},
    [1949]={solar_start=17897,lunar_start=17925,lunar_code=46423},
    [1950]={solar_start=18262,lunar_start=18309,lunar_code=27808},
    [1951]={solar_start=18627,lunar_start=18663,lunar_code=46416},
    [1952]={solar_start=18992,lunar_start=19018,lunar_code=86869},
    [1953]={solar_start=19358,lunar_start=19402,lunar_code=19872},
    [1954]={solar_start=19723,lunar_start=19756,lunar_code=42416},
    [1955]={solar_start=20088,lunar_start=20111,lunar_code=83315},
    [1956]={solar_start=20453,lunar_start=20495,lunar_code=21168},
    [1957]={solar_start=20819,lunar_start=20849,lunar_code=43432},
    [1958]={solar_start=21184,lunar_start=21232,lunar_code=59728},
    [1959]={solar_start=21549,lunar_start=21587,lunar_code=27296},
    [1960]={solar_start=21914,lunar_start=21941,lunar_code=44710},
    [1961]={solar_start=22280,lunar_start=22325,lunar_code=43856},
    [1962]={solar_start=22645,lunar_start=22680,lunar_code=19296},
    [1963]={solar_start=23010,lunar_start=23034,lunar_code=43748},
    [1964]={solar_start=23375,lunar_start=23418,lunar_code=42352},
    [1965]={solar_start=23741,lunar_start=23773,lunar_code=21088},
    [1966]={solar_start=24106,lunar_start=24126,lunar_code=62051},
    [1967]={solar_start=24471,lunar_start=24510,lunar_code=55632},
    [1968]={solar_start=24836,lunar_start=24865,lunar_code=23383},
    [1969]={solar_start=25202,lunar_start=25249,lunar_code=22176},
    [1970]={solar_start=25567,lunar_start=25603,lunar_code=38608},
    [1971]={solar_start=25932,lunar_start=25958,lunar_code=19925},
    [1972]={solar_start=26297,lunar_start=26342,lunar_code=19152},
    [1973]={solar_start=26663,lunar_start=26696,lunar_code=42192},
    [1974]={solar_start=27028,lunar_start=27050,lunar_code=54484},
    [1975]={solar_start=27393,lunar_start=27434,lunar_code=53840},
    [1976]={solar_start=27758,lunar_start=27788,lunar_code=54616},
    [1977]={solar_start=28124,lunar_start=28172,lunar_code=46400},
    [1978]={solar_start=28489,lunar_start=28526,lunar_code=46752},
    [1979]={solar_start=28854,lunar_start=28881,lunar_code=103846},
    [1980]={solar_start=29219,lunar_start=29265,lunar_code=38320},
    [1981]={solar_start=29585,lunar_start=29620,lunar_code=18864},
    [1982]={solar_start=29950,lunar_start=29974,lunar_code=43380},
    [1983]={solar_start=30315,lunar_start=30358,lunar_code=42160},
    [1984]={solar_start=30680,lunar_start=30712,lunar_code=45690},
    [1985]={solar_start=31046,lunar_start=31096,lunar_code=27216},
    [1986]={solar_start=31411,lunar_start=31450,lunar_code=27968},
    [1987]={solar_start=31776,lunar_start=31804,lunar_code=44870},
    [1988]={solar_start=32141,lunar_start=32188,lunar_code=43872},
    [1989]={solar_start=32507,lunar_start=32543,lunar_code=38256},
    [1990]={solar_start=32872,lunar_start=32898,lunar_code=19189},
    [1991]={solar_start=33237,lunar_start=33282,lunar_code=18800},
    [1992]={solar_start=33602,lunar_start=33636,lunar_code=25776},
    [1993]={solar_start=33968,lunar_start=33990,lunar_code=29859},
    [1994]={solar_start=34333,lunar_start=34373,lunar_code=59984},
    [1995]={solar_start=34698,lunar_start=34728,lunar_code=27480},
    [1996]={solar_start=35063,lunar_start=35112,lunar_code=23232},
    [1997]={solar_start=35429,lunar_start=35466,lunar_code=43872},
    [1998]={solar_start=35794,lunar_start=35821,lunar_code=38613},
    [1999]={solar_start=36159,lunar_start=36205,lunar_code=37600},
    [2000]={solar_start=36524,lunar_start=36559,lunar_code=51552},
    [2001]={solar_start=36890,lunar_start=36913,lunar_code=55636},
    [2002]={solar_start=37255,lunar_start=37297,lunar_code=54432},
    [2003]={solar_start=37620,lunar_start=37651,lunar_code=55888},
    [2004]={solar_start=37985,lunar_start=38006,lunar_code=30034},
    [2005]={solar_start=38351,lunar_start=38390,lunar_code=22176},
    [2006]={solar_start=38716,lunar_start=38744,lunar_code=43959},
    [2007]={solar_start=39081,lunar_start=39129,lunar_code=9680},
    [2008]={solar_start=39446,lunar_start=39483,lunar_code=37584},
    [2009]={solar_start=39812,lunar_start=39837,lunar_code=51893},
    [2010]={solar_start=40177,lunar_start=40221,lunar_code=43344},
    [2011]={solar_start=40542,lunar_start=40575,lunar_code=46240},
    [2012]={solar_start=40907,lunar_start=40929,lunar_code=47780},
    [2013]={solar_start=41273,lunar_start=41313,lunar_code=44368},
    [2014]={solar_start=41638,lunar_start=41668,lunar_code=21977},
    [2015]={solar_start=42003,lunar_start=42052,lunar_code=19360},
    [2016]={solar_start=42368,lunar_start=42406,lunar_code=42416},
    [2017]={solar_start=42734,lunar_start=42761,lunar_code=86390},
    [2018]={solar_start=43099,lunar_start=43145,lunar_code=21168},
    [2019]={solar_start=43464,lunar_start=43499,lunar_code=43312},
    [2020]={solar_start=43829,lunar_start=43853,lunar_code=31060},
    [2021]={solar_start=44195,lunar_start=44237,lunar_code=27296},
    [2022]={solar_start=44560,lunar_start=44591,lunar_code=44368},
    [2023]={solar_start=44925,lunar_start=44946,lunar_code=23378},
    [2024]={solar_start=45290,lunar_start=45330,lunar_code=19296},
    [2025]={solar_start=45656,lunar_start=45684,lunar_code=42726},
    [2026]={solar_start=46021,lunar_start=46068,lunar_code=42208},
    [2027]={solar_start=46386,lunar_start=46422,lunar_code=53856},
    [2028]={solar_start=46751,lunar_start=46776,lunar_code=60005},
    [2029]={solar_start=47117,lunar_start=47160,lunar_code=54576},
    [2030]={solar_start=47482,lunar_start=47515,lunar_code=23200},
    [2031]={solar_start=47847,lunar_start=47869,lunar_code=30371},
    [2032]={solar_start=48212,lunar_start=48253,lunar_code=38608},
    [2033]={solar_start=48578,lunar_start=48608,lunar_code=19195},
    [2034]={solar_start=48943,lunar_start=48992,lunar_code=19152},
    [2035]={solar_start=49308,lunar_start=49346,lunar_code=42192},
    [2036]={solar_start=49673,lunar_start=49700,lunar_code=118966},
    [2037]={solar_start=50039,lunar_start=50084,lunar_code=53840},
    [2038]={solar_start=50404,lunar_start=50438,lunar_code=54560},
    [2039]={solar_start=50769,lunar_start=50792,lunar_code=56645},
    [2040]={solar_start=51134,lunar_start=51176,lunar_code=46496},
    [2041]={solar_start=51500,lunar_start=51531,lunar_code=22224},
    [2042]={solar_start=51865,lunar_start=51886,lunar_code=21938},
    [2043]={solar_start=52230,lunar_start=52270,lunar_code=18864},
    [2044]={solar_start=52595,lunar_start=52624,lunar_code=42359},
    [2045]={solar_start=52961,lunar_start=53008,lunar_code=42160},
    [2046]={solar_start=53326,lunar_start=53362,lunar_code=43600},
    [2047]={solar_start=53691,lunar_start=53716,lunar_code=111189},
    [2048]={solar_start=54056,lunar_start=54100,lunar_code=27936},
    [2049]={solar_start=54422,lunar_start=54454,lunar_code=44448},
    [2050]={solar_start=54787,lunar_start=54809,lunar_code=84835},
    [2051]={solar_start=55152,lunar_start=55193,lunar_code=37744},
    [2052]={solar_start=55517,lunar_start=55548,lunar_code=18936},
    [2053]={solar_start=55883,lunar_start=55932,lunar_code=18800},
    [2054]={solar_start=56248,lunar_start=56286,lunar_code=25776},
    [2055]={solar_start=56613,lunar_start=56640,lunar_code=92326},
    [2056]={solar_start=56978,lunar_start=57023,lunar_code=59984},
    [2057]={solar_start=57344,lunar_start=57378,lunar_code=27296},
    [2058]={solar_start=57709,lunar_start=57732,lunar_code=108228},
    [2059]={solar_start=58074,lunar_start=58116,lunar_code=43744},
    [2060]={solar_start=58439,lunar_start=58471,lunar_code=37600},
    [2061]={solar_start=58805,lunar_start=58825,lunar_code=53987},
    [2062]={solar_start=59170,lunar_start=59209,lunar_code=51552},
    [2063]={solar_start=59535,lunar_start=59563,lunar_code=54615},
    [2064]={solar_start=59900,lunar_start=59947,lunar_code=54432},
    [2065]={solar_start=60266,lunar_start=60301,lunar_code=55888},
    [2066]={solar_start=60631,lunar_start=60656,lunar_code=23893},
    [2067]={solar_start=60996,lunar_start=61040,lunar_code=22176},
    [2068]={solar_start=61361,lunar_start=61394,lunar_code=42704},
    [2069]={solar_start=61727,lunar_start=61749,lunar_code=21972},
    [2070]={solar_start=62092,lunar_start=62133,lunar_code=21200},
    [2071]={solar_start=62457,lunar_start=62487,lunar_code=43448},
    [2072]={solar_start=62822,lunar_start=62871,lunar_code=43344},
    [2073]={solar_start=63188,lunar_start=63225,lunar_code=46240},
    [2074]={solar_start=63553,lunar_start=63579,lunar_code=46758},
    [2075]={solar_start=63918,lunar_start=63963,lunar_code=44368},
    [2076]={solar_start=64283,lunar_start=64318,lunar_code=21920},
    [2077]={solar_start=64649,lunar_start=64672,lunar_code=43940},
    [2078]={solar_start=65014,lunar_start=65056,lunar_code=42416},
    [2079]={solar_start=65379,lunar_start=65411,lunar_code=21168},
    [2080]={solar_start=65744,lunar_start=65765,lunar_code=45683},
    [2081]={solar_start=66110,lunar_start=66149,lunar_code=26928},
    [2082]={solar_start=66475,lunar_start=66503,lunar_code=29495},
    [2083]={solar_start=66840,lunar_start=66887,lunar_code=27296},
    [2084]={solar_start=67205,lunar_start=67241,lunar_code=44368},
    [2085]={solar_start=67571,lunar_start=67596,lunar_code=84821},
    [2086]={solar_start=67936,lunar_start=67980,lunar_code=19296},
    [2087]={solar_start=68301,lunar_start=68334,lunar_code=42352},
    [2088]={solar_start=68666,lunar_start=68689,lunar_code=21732},
    [2089]={solar_start=69032,lunar_start=69072,lunar_code=53600},
    [2090]={solar_start=69397,lunar_start=69426,lunar_code=59752},
    [2091]={solar_start=69762,lunar_start=69810,lunar_code=54560},
    [2092]={solar_start=70127,lunar_start=70164,lunar_code=55968},
    [2093]={solar_start=70493,lunar_start=70519,lunar_code=92838},
    [2094]={solar_start=70858,lunar_start=70903,lunar_code=22224},
    [2095]={solar_start=71223,lunar_start=71258,lunar_code=19168},
    [2096]={solar_start=71588,lunar_start=71612,lunar_code=43476},
    [2097]={solar_start=71954,lunar_start=71996,lunar_code=41680},
    [2098]={solar_start=72319,lunar_start=72350,lunar_code=53584},
    [2099]={solar_start=72684,lunar_start=72704,lunar_code=62034},
    [2100]={solar_start=73049,lunar_start=73088,lunar_code=54560},
}

local function year_days_acc(year)
    if year%4==0 and (year%100~=0 or year%400==0) then
        return {0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335}
    else
        return {0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334}
    end
end

local function binary_search(s, e, f)
    while s < e do
        local m = math.floor((s+e)/2)
        if not f(m) then s = s + 1 else e = m end
    end
    return s
end

local function lunar_month_days(code, month)
    return bit32.extract(code, 16-month) ~= 0 and 30 or 29
end

local function lunar_leap_month(code)
    local month = bit32.extract(code, 0, 4)
    if month == 0 then return 0, 0 end
    return bit32.extract(code, 16) ~= 0 and 30 or 29
end

local function solar_dn(year, month, day)
    if year < 1900 or year > 2100 then return -1 end
    return data[year].solar_start + year_days_acc(year)[month] + day-1
end

local function solar_ymd(dn)
    if dn < 0 or dn > 73413 then return -1,-1,-1 end
    local year = binary_search(1900, 2100, function(i) return data[i+1].solar_start > dn end)
    dn = dn - data[year].solar_start
    local acc = year_days_acc(year)
    local month = binary_search(1, 12, function(i) return acc[i+1] > dn end)
    dn = dn - acc[month]
    return year, month, dn+1
end

local function lunar_dn(year, month, day, leap)
    if year < 1900 or year > 2100 or (year==2100 and month==12 and day>1) then return -1 end
    local n = 0
    local code = data[year].lunar_code
    local leap_month, leap_days = lunar_leap_month(code)
    for i=1,month-1 do
        n = n + lunar_month_days(code, i)
        if i == leap_month then n = n + leap_days end
    end
    if leap then n = n + lunar_month_days(code, month) end
    return data[year].lunar_start + n + day-1
end

local function lunar_ymd(dn)
    if dn < 30 or dn > 73413 then return -1,-1,-1,false end
    local year = binary_search(1900, 2100, function(i) return data[i+1].lunar_start > dn end)
    dn = dn - data[year].lunar_start
    local code = data[year].lunar_code
    local leap_month, leap_days = lunar_leap_month(code)
    for i=1,12 do    
        local days = lunar_month_days(code, i)
        if dn < days then return year, i, dn+1, false else dn = dn - days end
        if i == leap_month then
            if dn < leap_days then return year, i, dn+1, true else dn = dn - leap_days end
        end
    end
end

local function solar_to_lunar(year, month, day)
    local dn = solar_dn(year, month, day)
    return lunar_ymd(dn)
end

local function lunar_to_solar(year, month, day, leap)
    local dn = lunar_dn(year, month, day, leap)
    return solar_ymd(dn)
end

local display = {
    digits = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"},
    months = {"正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"},
    days = {"初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
            "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
            "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"},
}

local function lunar_format(year, month, day, leap)
    return string.format("%s%s%s%s年",
        display.digits[tonumber(string.sub(tostring(year),1,1))+1],
        display.digits[tonumber(string.sub(tostring(year),2,2))+1],
        display.digits[tonumber(string.sub(tostring(year),3,3))+1],
        display.digits[tonumber(string.sub(tostring(year),4,4))+1])
        .. (leap and "闰" or "")
        .. display.months[month]
        .. display.days[day]
end

return {
    solar_dn = function(frame)
        local y, m, d = frame.args[1]:match("(%d+)%-(%d+)%-(%d+)")
        return solar_dn(tonumber(y), tonumber(m), tonumber(d))
    end,
    solar_ymd = function(frame)
        local y, m, d = solar_ymd(tonumber(frame.args[1]))
        return string.format("%d-%02d-%02d", y, m, d)
    end,
    lunar_dn = function(frame)
        local y, m, d = frame.args[1]:match("(%d+)%-(%d+)%-(%d+)")
        return lunar_dn(tonumber(y), tonumber(m), tonumber(d), frame.args[1]:match("%d+%-%d+%-%d+L") ~= nil)
    end,
    lunar_ymd = function(frame)
        local y, m, d, leap = lunar_ymd(tonumber(frame.args[1]))
        return string.format("%d-%02d-%02d%s", y, m, d, leap and "L" or "")
    end,
    solar_to_lunar = function(frame)
        local sy, sm, sd = frame.args[1]:match("(%d+)%-(%d+)%-(%d+)")
        local y, m, d, leap = solar_to_lunar(tonumber(sy), tonumber(sm), tonumber(sd))
        return string.format("%d-%02d-%02d%s", y, m, d, leap and "L" or "")
    end,
    lunar_to_solar = function(frame)
        local ly, lm, ld= frame.args[1]:match("(%d+)%-(%d+)%-(%d+)")
        local ll = frame.args[1]:match("%d+%-%d+%-%d+L") ~= nil
        local y, m, d = lunar_to_solar(tonumber(ly), tonumber(lm), tonumber(ld), ll)
        return string.format("%d-%02d-%02d", y, m, d)
    end,
    lunar_format = function(frame)
        local y, m, d= frame.args[1]:match("(%d+)%-(%d+)%-(%d+)")
        local l = frame.args[1]:match("%d+%-%d+%-%d+L") ~= nil
        return lunar_format(tonumber(y), tonumber(m), tonumber(d), l)
    end,
}
