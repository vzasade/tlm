SET (OPENJDK_RT_FILENAME "openjdk-${OPENJDK_VER}-rt.jar")
SET (URL "http://nas-n.mgt.couchbase.com/builds/downloads/openjdk-rt/${OPENJDK_RT_FILENAME}")
FILE (DOWNLOAD "${URL}" "${TARGET_DIR}/openjdk-rt.jar" STATUS _stat SHOW_PROGRESS)
LIST (GET _stat 0 _retval)
IF (_retval)
  # Don't leave corrupt/empty downloads
  IF (EXISTS "${file}")
    FILE (REMOVE "${file}")
  ENDIF (EXISTS "${file}")
  LIST (GET _stat 0 _errcode)
  LIST (GET _stat 1 _message)
  MESSAGE (FATAL_ERROR "Error downloading ${url}: ${_message} (${_errcode})")
ENDIF (_retval)
