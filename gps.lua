-- 火星坐标转换
--  {{#invoke:Gps|gcj02_to_gps84|39.91,116.397}} => 39.911403440504,116.40324363355
--  {{#invoke:Gps|gps84_to_gcj02|39.9114,116.4032}} => 39.909999277087,116.39699948772
-- algorithm based on https://www.jianshu.com/p/c39a2c72dc65

local ee = 0.00669342162296594323
local a = 6378245.0
local pi = math.pi

local function out_of_china(lat, lon)
    return lon < 72.004 or lon > 137.8347 or lat < 0.8293 or lat > 55.8271
end

local function transform_lat(x, y)
    return -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * math.sqrt(math.abs(x))
            + (20.0 * math.sin(6.0 * x * pi) + 20.0 * math.sin(2.0 * x * pi)) * 2.0 / 3.0
            + (20.0 * math.sin(y * pi) + 40.0 * math.sin(y / 3.0 * pi)) * 2.0 / 3.0
            + (160.0 * math.sin(y / 12.0 * pi) + 320 * math.sin(y * pi / 30.0)) * 2.0 / 3.0
end

local function transform_lon(x, y)
    return 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * math.sqrt(math.abs(x))
            + (20.0 * math.sin(6.0 * x * pi) + 20.0 * math.sin(2.0 * x * pi)) * 2.0 / 3.0
            + (20.0 * math.sin(x * pi) + 40.0 * math.sin(x / 3.0 * pi)) * 2.0 / 3.0
            + (150.0 * math.sin(x / 12.0 * pi) + 300.0 * math.sin(x / 30.0* pi)) * 2.0 / 3.0;
end

local function transform(lat, lon)
    if out_of_china(lat, lon) then return lat, lon end
    local dlat = transform_lat(lon - 105.0, lat - 35.0)
    local dlon = transform_lon(lon - 105.0, lat - 35.0)
    local rad_lat = lat / 180.0 * pi
    local magic = math.sin(rad_lat)
    magic = 1 - ee * magic * magic
    local sqrt_magic = math.sqrt(magic)
    dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrt_magic) * pi)
    dlon = (dlon * 180.0) / (a / sqrt_magic * math.cos(rad_lat) * pi)
    return lat+dlat, lon+dlon
end

local function gcj02_to_gps84(lat, lon)
    local lat1, lon1 = transform(lat, lon)
    return lat*2-lat1, lon*2-lon1
end

local function gps84_to_gcj02(lat, lon)
    if out_of_china(lat, lon) then return lat, lon end
    local dlat = transform_lat(lon - 105.0, lat - 35.0)
    local dlon = transform_lon(lon - 105.0, lat - 35.0)
    local rad_lat = lat / 180.0 * pi
    local magic = math.sin(rad_lat)
    magic = 1 - ee * magic * magic
    local sqrt_magic = math.sqrt(magic)
    dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrt_magic) * pi)
    dlon = (dlon * 180.0) / (a / sqrt_magic * math.cos(rad_lat) * pi)
    return lat+dlat, lon+dlon
end

local function convert(s, f)
    local coord = {}
    for i in string.gmatch(s, "[^$s,]+") do
        table.insert(coord, tonumber(i))
    end
    local lat, lon = f(coord[1], coord[2])
    return tostring(lat)..","..tostring(lon)
end

return {
    gcj02_to_gps84 = function(frame) return convert(frame.args[1], gcj02_to_gps84) end,
    gps84_to_gcj02 = function(frame) return convert(frame.args[1], gps84_to_gcj02) end
}