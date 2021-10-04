get-cmdriverpackage | foreach {
  if ($_.pkgflags -eq ($_.pkgflags -bor 0x80)) {
  "pkg share bit enabled on {0}" -f $_.Packageid
  }
}

