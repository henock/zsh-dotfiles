# copied from the oh-my-zsh/plugins/jsontools plugin and modified to my needs

function pp_json() {
  python -c 'import sys; del sys.path[0]; import runpy; runpy._run_module_as_main("json.tool")'
}

function is_json() {
  python -c '
import sys; del sys.path[0];
import json
try:
  json.loads(sys.stdin.read())
  print("true"); sys.exit(0)
except ValueError:
  print("false"); sys.exit(1)
'
}