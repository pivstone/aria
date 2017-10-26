ExUnit.start()
File.rm_rf(Storage.PathSpec.data_dir())
File.cp_r!("test/fixtures", Storage.PathSpec.data_dir())