import yaml
import file

_dump_with_header = lambda obj, file_name: str, header: str {
    _dumped = yaml.encode(obj)
    file.write(file_name, header + _dumped)
    _ = {}
}

_dump_all_with_header = lambda obj, file_name: str, header: str {
    _dumped = yaml.encode_all(obj)
    file.write(file_name, header + _dumped)
    _ = {}
}