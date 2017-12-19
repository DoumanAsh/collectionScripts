#Downloads boost with specified version.
#Function sets following variables:
# - BOOST_ROOT - location of download.
# - BOOST_INCLUDEDIR - Boost headers.
function(lazy_boost version)
    #https://dl.bintray.com/boostorg/release/1.66.0/source/boost_1_66_0.zip
    string(REPLACE . _ version2 ${version})

    include(ExternalProject)
    ExternalProject_Add(
        boost
        PREFIX "boost"
        URL "https://dl.bintray.com/boostorg/release/${version}/source/boost_${version2}.zip"
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ""
    )

    ExternalProject_Get_Property(boost download_dir)
    set(boost_dir ${download_dir})

    set(BOOST_ROOT ${boost_dir} PARENT_SCOPE)
    set(BOOST_INCLUDEDIR "${boost_dir}/boost" PARENT_SCOPE)
endfunction()
