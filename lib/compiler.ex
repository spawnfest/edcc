defmodule Compiler do
    def compile({{name, file}, []}) do
      File.mkdir("tmp_files_to_compile")
      Helper.save_file_in({name, file}, "tmp_files_to_compile")
      File.cd!("tmp_files_to_compile", fn -> System.cmd("gcc", ["-c", name]) end)
      {name, binary_file} = 
      File.cd!("tmp_files_to_compile", fn -> 
        String.replace_suffix(name, ".c", ".o")
        |> Helper.get_binary() 
      end)
      File.rm_rf("tmp_files_to_compile")
      {name, binary_file}
    end
    def compile({{name, file}, deps}) do
      File.mkdir("tmp_files_to_compile")
      Helper.save_file_in({name, file}, "tmp_files_to_compile")
      Enum.map(deps, fn {a, b} -> Helper.save_file_in({a, b}, "tmp_files_to_compile") end)
      Enum.map(deps, fn {dep_name, _} -> dep_name end)
      File.cd!("tmp_files_to_compile", fn -> System.cmd("gcc", ["-c", name]) end)
      compiled = 
      File.cd!("tmp_files_to_compile", fn -> 
        String.replace_suffix(name, ".c", ".o") 
        |> Helper.get_binary() 
      end)
      File.rm_rf("tmp_files_to_compile")
      compiled
    end
end