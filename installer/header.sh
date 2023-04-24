#!/bin/bash

export TMPDIR=`mktemp -d "/tmp/installer.$USER.XXXXXX"`
ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' $0`

echo ""
echo "Extracting $0 to $TMPDIR"
echo ""

tail -n+$ARCHIVE $0 | tar xz -C $TMPDIR
pushd "$TMPDIR" >> /dev/null 
  sudo bash ./installer/install.sh hosts/*/
popd >> /dev/null
rm -rf $TMPDIR

exit 0
__ARCHIVE_BELOW__
