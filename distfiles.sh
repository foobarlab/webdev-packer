#!/bin/bash

create_sum() {
	# TODO check given param(s)
	#find "$PWD" -type d |\
	find "$PWD/$1" -type d |\
	sort |\
	while read dir; \
	do cd "${dir}"; \
		[ ! -f checksums.b2 ] && echo "Processing " "${dir}" || echo "Skipped " "${dir}" " checksums.b2 allready present" ; \
		[ ! -f checksums.b2 ] &&  b2sum * > checksums.b2 ; \
		chmod a=r "${dir}"/checksums.b2 ; \
	done
}

check_sum() {
	# TODO check given param(s)
	#find "$PWD" -name @md5Sum.md5 | \
	find "$PWD/$1" -name checksums.b2 | \
	sort | \
	while read file; \
		do cd "${file%/*}"; \
		b2sum -c checksums.b2; \
	done > checksums.log
}

echo "TODO check distfiles"

check_sum distfiles
cat checksums.log

echo "TODO download distfiles if missing file checksums found (count files) ..."

# ant-1.10.9-gentoo.tar.bz2: https://dev.gentoo.org/~fordfrog/distfiles/ant-1.10.9-gentoo.tar.bz2
# mariadb-10.5.9.tar.gz: https://downloads.mariadb.org/interstitial/mariadb-10.5.9/source/mariadb-10.5.9.tar.gz/from/https%3A//archive.mariadb.org/

echo "TODO re-create checksum if needed ..."

create_sum distfiles

echo "TODO re-check checksums, abort/continue if distfiles were still missing or download failed."

check_sum distfiles
cat checksums.log
