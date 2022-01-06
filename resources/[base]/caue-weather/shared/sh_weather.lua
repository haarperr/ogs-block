function round(n, precision)
	if precision then
		return math.floor((n * 10^precision) + 0.5 ) / (10^precision)
	end
	return math.floor(n + 0.5)
end