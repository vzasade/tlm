#
# Choose deployment target on MacOS
#
IF (APPLE)
  # See http://www.couchbase.com/issues/browse/MB-11442
  SET (CMAKE_OSX_DEPLOYMENT_TARGET "10.7" CACHE STRING
    "Minimum supported version of MacOS X")
ENDIF (APPLE)

# Create a list of all of the directories we would like to be treated
# as system headers (and not report compiler warnings from (if the
# compiler supports it). This is used by the compiler-specific Options
# cmake files below.
#
# Note that as a side-effect this will change the compiler
# search order - non-system paths (-I) are searched before
# system paths.
# Therefore if a header file exists both in a standard
# system location (e.g. /usr/local/include) and in one of
# our paths then adding to CB_SYSTEM_HEADER_DIRS may
# result in the compiler picking up the wrong version.
# As a consequence of this we only add headers which
# (1) have known warning issues and (2) are unlikely
# to exist in a normal system location.

# Explicitly add Google Breakpad as it's headers have
# many warnings :(
IF (IS_DIRECTORY "${BREAKPAD_INCLUDE_DIR}")
   LIST(APPEND CB_SYSTEM_HEADER_DIRS "${BREAKPAD_INCLUDE_DIR}")
ENDIF (IS_DIRECTORY "${BREAKPAD_INCLUDE_DIR}")

#
# Set flags for the C Compiler
#
IF ("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU")
  INCLUDE(CouchbaseGccOptions)
ELSEIF ("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")
  INCLUDE(CouchbaseClangOptions)
ELSEIF ("${CMAKE_C_COMPILER_ID}" STREQUAL "MSVC")
  INCLUDE(CouchbaseMsvcOptions)
ELSE ()
  MESSAGE(FATAL_ERROR "Unsupported C compiler: ${CMAKE_C_COMPILER_ID}")
ENDIF()

#
# Set flags for the C++ compiler
#
IF ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
  INCLUDE(CouchbaseGxxOptions)
ELSEIF ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
  INCLUDE(CouchbaseClangxxOptions)
ELSEIF ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
  INCLUDE(CouchbaseMsvcxxOptions)
ELSE ()
    MESSAGE(FATAL_ERROR "Unsupported C++ compiler: ${CMAKE_C_COMPILER_ID}")
ENDIF ()

# Add common -D sections
INCLUDE(CouchbaseDefinitions)

# Setup the RPATH
INCLUDE(CouchbaseRpath)

# Check function attibute availability
# - warn_used_result
INCLUDE(CheckCCompilerFlag)
CHECK_C_SOURCE_COMPILES("int main() {
      return 0;
}
int foo() __attribute__((warn_unused_result));" HAVE_ATTR_WARN_UNUSED_RESULT)

# - printf-style format checking
INCLUDE(CheckCCompilerFlag)
CHECK_C_SOURCE_COMPILES("int main() {
      return 0;
}
int my_printf(const char* fmt, ...) __attribute__((format (printf, 1, 2)));" HAVE_ATTR_FORMAT)

# - noreturn for functions not returning
INCLUDE(CheckCCompilerFlag)
CHECK_C_SOURCE_COMPILES("int main() {
      return 0;
}
int foo(void) __attribute__((noreturn));" HAVE_ATTR_NORETURN)

# - nonnull parameters that can't be null
INCLUDE(CheckCCompilerFlag)
CHECK_C_SOURCE_COMPILES("int main() {
      return 0;
}
int foo(void* foo) __attribute__((nonnull(1)));" HAVE_ATTR_NONNULL)

# - deprecated
INCLUDE(CheckCCompilerFlag)
CHECK_C_SOURCE_COMPILES("int main() {
      return 0;
}
int foo(void* foo) __attribute__((deprecated));" HAVE_ATTR_DEPRECATED)


IF (NOT DEFINED COUCHBASE_DISABLE_CCACHE)
   FIND_PROGRAM(CCACHE ccache)

   IF (CCACHE)
      GET_FILENAME_COMPONENT(_ccache_realpath ${CCACHE} REALPATH)
      GET_FILENAME_COMPONENT(_cc_realpath ${CMAKE_C_COMPILER} REALPATH)

      IF (_ccache_realpath STREQUAL _cc_realpath)
          MESSAGE(STATUS "seems like ccache is already used via masquerading")
      ELSE ()
          MESSAGE(STATUS "ccache is available as ${CCACHE}, using it")
          SET_PROPERTY(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${CCACHE})
          SET_PROPERTY(GLOBAL PROPERTY RULE_LAUNCH_LINK ${CCACHE})
      ENDIF ()
   ENDIF (CCACHE)
ENDIF (NOT DEFINED COUCHBASE_DISABLE_CCACHE)
