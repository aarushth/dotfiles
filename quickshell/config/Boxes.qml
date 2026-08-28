pragma Singleton
import QtQuick

QtObject{
	property int boxSize: 12
	property var preSlice: []
	property var cache: ({})          // "<length>|<bias>" -> boxes

	function getBoxes(length, calcBiasFunc = undefined, biasKey = "none"){
		let key = length + "|" + biasKey
		let hit = cache[key]
		if (hit !== undefined) return hit

		if (length > preSlice.length) expandTo(length)

		let boxes = sliceVals(length, calcBiasFunc)
		cache[key] = boxes
		return boxes
	}

	function expandTo(length){
		for (let i = preSlice.length; i < length; i++){
			preSlice.push({ id: i, score: Math.random() })
		}
	}

	function sliceVals(length, calcBiasFunc){
		let newBoxes = new Array(length)
		let temp = new Array(length)
		for (let i = 0; i < length; i++){
			let score = preSlice[i].score
			temp[i] = {
				id: preSlice[i].id,
				score: calcBiasFunc != null
					? calcBiasFunc(i) * 0.8 + score * 0.2
					: score
			}
		}
		temp.sort((a, b) => b.score - a.score)
		for (let i = 0; i < temp.length; i++) newBoxes[temp[i].id] = i
		return newBoxes
	}
}
