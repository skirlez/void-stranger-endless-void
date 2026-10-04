event_inherited();

if (state == 0) {
	download_timeout--;
	if (download_timeout == 0) {
		on_fail("Timeout")
	}
}
