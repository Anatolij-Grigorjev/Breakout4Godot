class_name Utils
"""
Static utility methods
"""


"""
Join elements of an Array as a string  using the 
'joiner' delimiter.
Each element is stringified using the 'formatter' format string.
"""
static func joinToString(
	col: Array, joiner = ",", formatter: String = "%s"
) -> String:
	var stringPool := PoolStringArray()
	for item in col:
		stringPool.append(formatter % item)
	return stringPool.join(joiner)

"""
Print current values stored in listed object properties,
one property=value pair per line
"""
static func dumpObjectScriptVars(object: Object) -> String:
	var currentPropValues := ["<%s>" % object.get_class()]
	for prop in object.get_property_list():
		if (prop.usage == PROPERTY_USAGE_SCRIPT_VARIABLE):
			currentPropValues.append("\t%s=%s" % [prop.name, object.get(prop.name)])
	currentPropValues.append("</%s>" % object.get_class())
	
	return joinToString(currentPropValues, "\n")
	
	
static func dumpObjectAllProperties(object: Object) -> String:
	var currentPropValues := ["<%s>" % object.get_class()]
	for prop in object.get_property_list():
		currentPropValues.append("\t%s=%s" % [prop.name, object.get(prop.name)])
	currentPropValues.append("</%s>" % object.get_class())	
	return joinToString(currentPropValues, "\n")
	

"""
Attempt to connect 'signal' from 'source' to 'method' on 'target', 
with specified binds.
NOOP if connection exists. 
default connect flags.
Returns 'true' if a new signal connection was made, 'false' otherwise
"""
static func tryConnect(
	source: Object, sourceSignal: String, 
	target: Object, method: String,
	binds: Array = []
) -> bool:
	if not (is_instance_valid(source) and is_instance_valid(target)):
		print("CONNECT_ERROR: either source or target instance was missing! Cant connect %s '%s' to %s '%s'" % [
			source, sourceSignal, target, method
		])
		return false
	if (source.is_connected(sourceSignal, target, method)):
		return false
	var connectError = source.connect(sourceSignal, target, method, binds)
	if (connectError != OK):
		print("CONNECT_ERROR: '%s' emit [%s] -> '%s' handler [%s]: %s" % [
			source.name, sourceSignal,
			target.name, method,
			connectError
		])
	else:
		print("CONNECT: '%s' emit [%s] -> '%s' handler [%s]" % [
			source.name, sourceSignal, target.name, method
		])
	return connectError == OK


"""
Get contents of file as a string
"""
static func getFileText(filePath: String) -> String:
	var file: File = File.new()
	var fileOpenError = file.open(filePath, File.READ)
	if fileOpenError != OK:
		print("Error opening file at '%s'! Error code: %s" % [filePath, fileOpenError])
		breakpoint
	var fileText: String = file.get_as_text()
	file.close()
	return fileText
	
	
	

"""
Append value 'elem' into array 'arr' 'num' times. Appends linearly in a loop.
Method mutates supplied array, so 'arr' cannot be null.
if num <= 0 the input array is unchanged, 
if num = 1 the method delegates to Array#append
"""
static func appendNTimes(arr: Array, elem, num: int = 1):
	assertNotNull(arr)
	if num <= 0:
		return
	if num == 1:
		arr.append(elem)
		return
	for counter in range(num):
		arr.append(elem)


"""
Resolve a list of valid nodepaths into a list of nodes they point to
Skips invalid paths
"""
static func resolveNodePathsList(origin: Node, relativePaths: Array) -> Array:
	
	if not is_instance_valid(origin):
		return []
		
	var resolvedNodes := [];
	for item in relativePaths:
		var relativePath = item as NodePath
		if is_instance_valid(relativePath):
			var resolvedNode: Node = origin.get_node(relativePath)
			if is_instance_valid(resolvedNode):
				resolvedNodes.append(resolvedNode)
	return resolvedNodes

	
"""
Parse the file at path 'filePath' as valid JSON and return the structure
(list or object)
"""
static func file2JSON(filePath: String):
	var fileText: String = getFileText(filePath)
	var parseResult: JSONParseResult = JSON.parse(fileText)
	if parseResult.error != OK:
		print("Error parsing JSON string!\n%s.\nError code: %s, '%s' on line: %s" % [
			fileText,
			parseResult.error,
			parseResult.error_string,
			parseResult.error_line
		])
		breakpoint
	return parseResult.result


"""
Generate random Vector2 with coordinates between
(-maxX;-maxY) and (maxX;maxY)
"""
static func randomPoint(maxX: float, maxY: float) -> Vector2:
	return Vector2(rand_range(-maxX, maxX), rand_range(-maxY, maxY))


"""
Returns an array that is the result of removing all excludeElems elements
from the base array specified by allElems
Creates new array. Doesnt modify any inputs. 
If base array is null return empty. If remove array is empty/null returns base.
"""
static func removeAllFrom(baseElems: Array, excludeElems: Array) -> Array:
	if baseElems == null:
		return []
	if excludeElems == null or excludeElems.empty():
		return baseElems
	var filteredElems = []
	for elem in baseElems:
		if not elem in excludeElems:
			filteredElems.append(elem)
	return filteredElems


"""
Returns a vector with coordinates swapped with respect to input vector
So for a given passed Vector2(x,y) will return Vector2(y,x)
Returns null for null input
"""
static func swapVector(input: Vector2) -> Vector2:
	#if null or zero then return same
	if (not input):
		return input
	return Vector2(input.y, input.x)

	

# Safely get first element from possibly null or empty array.
# If the array is null or empty the return is null
static func getFirst(arr: Array):
	if (arr == null or arr.empty()):
		return null
	return arr[0] 
	
	
"""
Find first node belonging to specified group in specified scene tree
Returns null if no nodes in group found
"""
static func getFirstTreeNodeInGroup(treeRef: SceneTree, groupName: String):
	return getFirst(treeRef.get_nodes_in_group(groupName))
	
	
"""
Check if a given string is null or empty
"""
static func isEmptyString(string: String) -> bool:
	return string == null or string.empty()
	

"""
Assert that supplied value is not null
"""
static func assertNotNull(elem):
	assert(elem != null)
	
	
"""
Get array element at random index. Doesnt modify the input array
Short circuit if array is of size 1 or less
"""
static func getRandom(elems: Array):
	if (elems == null or elems.empty()):
		return null
	if (elems.size() == 1):
		return elems[0]
	
	return elems[randi() % elems.size()]
	
	
"""
Attempt to map provided list of objects into a list of same ordering containing 
the object property value at provided property path
if the path is invalid for any object in the input list, a 'null' is set for 
that element
Always returns some kind of list, never null
"""
static func mapToProp(objectsArray: Array, propPath: String) -> Array:
	if objectsArray == null or objectsArray.empty():
		return []
	var propValues = [].resize(objectsArray.size())
	for idx in range(objectsArray.size()):
		var object = objectsArray[idx]
		var propValue = object.get(propPath)
		propValues[idx] = propValue
		
	return propValues
	
"""
Attempt to associate provided list of objects into a dictionary 
with key being object property value at provided property path
if the path is invalid for any object in the input list, the method will 
associate that object with the 'null' key
In case of keys clash the latest object with this key value wins
Always returns some kind of dict, never null
"""
static func assocToProp(objectsArray: Array, propPath: String) -> Dictionary:
	if objectsArray == null or objectsArray.empty():
		return {}
	var associatedObjects := {}
	for idx in range(objectsArray.size()):
		var object = objectsArray[idx]
		var propValue = object.get(propPath)
		associatedObjects[propValue] = object
		
	return associatedObjects


"""
Get list of all child nodes of the given node that are part of the
specified group
"""
static func getNodeChildrenInGroup(parentNode: Node, group: String) -> Array:
	if not is_instance_valid(parentNode):
		return []
	var childrenInGroup := []
	for node in parentNode.get_children():
		if is_instance_valid(node) and node.is_in_group(group):
			childrenInGroup.append(node)
	return childrenInGroup
	
	
	
"""
Get list of all immediate child nodes of the given node that are of 
specific Node type, identified by "is" check
"""
static func getNodeChildrenOfType(parentNode: Node, Type) -> Array:
	if not is_instance_valid(parentNode):
		return []
	var childrenOfType := []
	for node in parentNode.get_children():
		if is_instance_valid(node) and node is Type:
			childrenOfType.append(node)
	return childrenOfType


"""
Get list of filenames at supplied directory path. 
Invalid directory path produces an empty list. 
Subdirectories and unix navigation links are ignored.
Filenames are returned in directory iteration order. Returned filenames
can be further filtered by suppling optional suffix
"""
static func getFilenamesInDirectory(dirPath: String, requiredFileNameSuffix: String = "") -> Array:
	var directoryHandle = Directory.new()
	var directoryOpenStatusCode = directoryHandle.open(dirPath)
	if directoryOpenStatusCode != OK:
		print("ERROR: opening directory '%s', status code: %s" % [dirPath, directoryOpenStatusCode])
		return []
	var skipUnixNavigationalDirs = true
	var skipHiddenFiles = true
	var startDirectoryListingStatus = directoryHandle.list_dir_begin(
		skipUnixNavigationalDirs, skipHiddenFiles
	)
	if startDirectoryListingStatus != OK:
		print("ERROR: starting directory listing from dir handle %s, status: %s" % [directoryHandle, startDirectoryListingStatus])
		return []
	var foundMatchingFilenames := []
	var nextDirectoryEntry: String = directoryHandle.get_next()
	while not isEmptyString(nextDirectoryEntry):
		if (
			not directoryHandle.current_is_dir()
			and nextDirectoryEntry.ends_with(requiredFileNameSuffix)
			):
				foundMatchingFilenames.append(nextDirectoryEntry)
		nextDirectoryEntry = directoryHandle.get_next()
		
	return foundMatchingFilenames
	
	

"""
Combine 2 path segments into a single path, deduplicating any potential 
path markers
"""
static func combinePathParts(part1: String, part2: String) -> String:
	if isEmptyString(part1):
		return part2
	if isEmptyString(part2):
		return part1
	
	var pathDelimiter: String = "/"
	var partsSupplyDelimiter: bool = part1.ends_with(pathDelimiter) != part2.begins_with(pathDelimiter)
	
	if partsSupplyDelimiter:
		return part1 + part2
	
	#they both border on delimiter, need to deduplicate
	if part2.begins_with(pathDelimiter):
		return part1 + part2.substr(pathDelimiter.length())
	#neither has delimiter, must add between
	else:
		return part1 + pathDelimiter + part2
