pragma Singleton
import QtQuick

QtObject{
	property int boxSize: 12
	property var preSlice: []
	property var cache: ({})          // "<length>|<bias>" -> boxes
	property var biasIds: new WeakMap()
	property int nextBiasId: 0

	function biasId(fn){
		if (fn == null) return "none"
		let id = biasIds.get(fn)
		if (id === undefined){
			id = ++nextBiasId
			biasIds.set(fn, id)
		}
		return "fn" + id
	}

	function getBoxes(length, calcBiasFunc = undefined){
		if (length > preSlice.length) expandTo(length)

		let key = length + "|" + biasId(calcBiasFunc)
		let hit = cache[key]
		if (hit !== undefined) return hit

		let boxes = sliceVals(length, calcBiasFunc)
		cache[key] = boxes
		return boxes
	}

	function expandTo(length){
		let addition = new Array(length - preSlice.length)
		for (let i = preSlice.length; i < length; i++){
			addition[i - preSlice.length] = { id: i, score: Math.random() }
		}
		preSlice = preSlice.concat(addition)
	}

	function sliceVals(length, calcBiasFunc){
		let newBoxes = new Array(length)
		// copy the entries: never mutate preSlice's scores
		let temp = new Array(length)
		for (let i = 0; i < length; i++){
			let score = preSlice[i].score
			temp[i] = {
				id: preSlice[i].id,
				score: calcBiasFunc != null
					? calcBiasFunc(i, score) * 0.8 + score * 0.2
					: score
			}
		}
		temp.sort((a, b) => b.score - a.score)
		for (let i = 0; i < temp.length; i++) newBoxes[temp[i].id] = i
		return newBoxes
	}
}
