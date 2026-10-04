if ds_map_find_value(async_load, "id") == download_pack
{
    var status = ds_map_find_value(async_load, "status");
	if status == 0 
    {
        pack_string = ds_map_find_value(async_load, "result");
        if save_online_pack(nodeless_pack.save_name, pack_string) {
            on_success(pack_string)
        } else {
            on_fail("Failed to save pack")
        }
	}   
    else if status < 0 
    {
        state = DownloadState.ERROR
    }
}