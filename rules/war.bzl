# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Create a Web ARchive file

Cribbed from Java AppEngine support for Bazel.

For now, it only support bundling a WebApp.

To create a WAR file, add the rules:
war_file(
  name = "MyWebApp",
  # Jars to use for the classpath in the webapp.
  jars = ["//java/com/google/examples/mywebapp:java"],
  # data to put in the webapp, the directory structure of the data set
  # will be maintained.
  data = ["//java/com/google/examples/mywebapp:data"],
  # Data's root path, it will be considered as the root of the data files.
  # If unspecified, the path to the current package will be used. The path is
  # relative to current package or, relative to the workspace root if starting
  # with a leading slash.
  data_path = "/java/com/google/examples/mywebapp",
)

"""

jar_filetype = FileType([".jar"])

def _add_file(in_file, output, path = None):
  output_path = output
  input_path = in_file.path
  if path and input_path.startswith(path):
    output_path += input_path[len(path):]
  return [
      "mkdir -p $(dirname %s)" % output_path,
      "test -L %s || ln -s $(pwd)/%s %s\n" % (output_path, input_path,
                                              output_path)
      ]

def _make_war(zipper, input_dir, output):
  return [
      "(root=$(pwd);" +
      ("cd %s &&" % input_dir) +
      ("${root}/%s Cc ${root}/%s $(find *))" % (zipper.path, output.path))
      ]

def _short_path_dirname(path):
  sp = path.short_path
  return sp[0:len(sp)-len(path.basename)-1]

def _war_impl(ctxt):
  zipper = ctxt.file._zipper

  data_path = ctxt.attr.data_path
  if not data_path:
    data_path = _short_path_dirname(ctxt.outputs.war)
  elif data_path[0] == "/":
    data_path = data_path[1:]
  else:  # relative path
    data_path = _short_path_dirname(ctxt.outputs.war) + "/" + data_path

  war = ctxt.outputs.war
  build_output = war.path + ".build_output"
  cmd = [
      "set -e;rm -rf " + build_output,
      "mkdir -p " + build_output
      ]

  inputs = ctxt.files.jars + [zipper]
  cmd += ["mkdir -p %s" % build_output + "/WEB-INF/lib"]
  for jar in ctxt.files.jars:
    # Add the jar to WEB-INF/lib.
    cmd += _add_file(jar, build_output + "/WEB-INF/lib")
    # Add its runtime classpath to WEB-INF/lib
    if hasattr(jar, "java"):
      inputs += jar.java.transitive_runtime_deps
      for run_jar in jar.java.transitive_runtime_deps:
        cmd += _add_file(run_jar, build_output + "/WEB-INF/lib")

  inputs += ctxt.files.data
  for res in ctxt.files.data:
    # Add the data file
    cmd += _add_file(res, build_output, path = data_path)

  cmd += _make_war(zipper, build_output, war)

  ctxt.action(
      inputs = inputs,
      outputs = [war],
      mnemonic="WAR",
      command="\n".join(cmd),
      use_default_shell_env=True)

  runfiles = ctxt.runfiles(files = [war, ctxt.file._java, ctxt.file._zipper])
  return struct(runfiles = runfiles)

war_file = rule(
    _war_impl,
    attrs = {
        "_java": attr.label(
            default = Label("@bazel_tools//tools/jdk:java"),
            single_file = True,
        ),
        "_zipper": attr.label(
            default = Label("@bazel_tools//third_party/ijar:zipper"),
            single_file = True,
        ),
        "jars": attr.label_list(
            allow_files = jar_filetype,
            mandatory = True,
        ),
        "data": attr.label_list(allow_files = True),
        "data_path": attr.string(),
    },
    outputs = {
        "war": "%{name}.war",
    },
)
