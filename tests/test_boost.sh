#!/bin/bash -e
cat <<EOF | g++ -o /tmp/a.out -xc++ -std=c++11 - && /tmp/a.out
#include <boost/convert.hpp>
#include <boost/convert/lexical_cast.hpp>

int main(){ 
    int i1 = boost::lexical_cast<int>("123");
    if (i1 == 123)
        return 0;
    return 1;
}
EOF

cat <<EOF | g++ -o /tmp/a.out -xc++ -std=c++11 - && /tmp/a.out
#include <boost/vmd/is_seq.hpp>  // new in Boost 1.60

int main(void){
    return 0;
}
EOF
