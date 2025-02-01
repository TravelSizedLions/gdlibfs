@tool
class_name FS extends Node

static func search_dir(path: String, search_pattern: String = "", recursive: bool = false):
  search_pattern = "*" if search_pattern == "" else search_pattern
  var dir = DirAccess.open(path)

  if not dir:
    var error = "Could not open dir at path: \"%s\"" % path
    printerr(error)
    push_error(error)
    return []

  dir.list_dir_begin()
  var files = []
  var full_path = path

  var file = dir.get_next()
  while file != "":
    if dir.current_is_dir():
      if recursive:
        var file_full_path = "%s/%s" % [full_path.trim_suffix('/'), file]
        files.append_array(search_dir(file_full_path, search_pattern, recursive))
      else:
        pass
    elif file.match(search_pattern):
      files.append("%s/%s" % [full_path.trim_suffix('/'), file])

    file = dir.get_next()        

  return files

static func get_scripts_with_property(prop: String, options = {}):
  var path = Funk.option(options, 'path', 'res://')
  var search_pattern = Funk.option(options, 'search_pattern', '*.gd')
  var recursive = Funk.option(options, 'recursive', true)
  var return_loaded = Funk.option(options, 'return_loaded', true)
  return search_dir(path, search_pattern, recursive).reduce((
    func (acc, file_path):
      var script = load(file_path) as GDScript
      var props = script.get_script_property_list()
      if script && props.any(func (p): return p.name == prop):
        acc.append(script if return_loaded else file_path)
      return acc
  ), [])
