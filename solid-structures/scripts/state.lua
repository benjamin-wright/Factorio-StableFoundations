local State = {}

function State.init()
	storage.ssTracked = storage.ssTracked or {}
	storage.ssBonusBeacons = storage.ssBonusBeacons or {}
end

function State.clear(uid)
	if storage.ssTracked then storage.ssTracked[uid] = nil end
end

return State
