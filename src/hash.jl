# const DICT = "/usr/share/dict/words"

# Based on http://stevehanov.ca/blog/?id=119

# Calculates a distinct hash function for a given string. Each value of the
# integer d results in a different hash value.
function fnv_hash(s, d::UInt32 = 0x811c9dc5)

    # Use the FNV algorithm from http://isthe.com/chongo/tech/comp/fnv/
    for c in s
        d *= 0x01000193
        d = d ⊻ c
    end

    return d
end

function jenkins_one_at_a_time_hash(key, length)
    i = 1
    hash = UInt32(0)
    while i != length + 1
        hash += key[i]
        i += 1
        hash += hash << 10
        hash ^= hash >> 6
    end
    hash += hash << 3
    hash ^= hash >> 11
    hash += hash << 15
    return hash
end

hashsize(n) = UInt32(1) << n
hashmask(n) = hashsize(n) - UInt32(1)

@inline function mix(a::UInt32, b::UInt32, c::UInt32)
      a -= b; a -= c; a |= (c>>13);
      b -= c; b -= a; b |= (a<<8);
      c -= a; c -= b; c |= (b>>13);
      a -= b; a -= c; a |= (c>>12);
      b -= c; b -= a; b |= (a<<16);
      c -= a; c -= b; c |= (b>>5);
      a -= b; a -= c; a |= (c>>3);
      b -= c; b -= a; b |= (a<<10);
      c -= a; c -= b; c |= (b>>15);
      a, b, c
end


function jenkins(key, initval)
    len = UInt32(length(key))
    a = b = 0x9e3779b9  # the golden ratio; an arbitrary value
    c = initval

    i = 1
    while len >= 12
        @inbounds a += key[i] + key[i+1] << 8 + key[i+2] << 16 + key[i+3] << 24
        @inbounds b += key[i+4] + key[i+5] << 8 + key[i+6] << 16 + key[i+7] << 24
        @inbounds c += key[i+8] + key[i+9] << 8 + key[i+10] << 16 + key[i+11] << 24
        a, b, c = mix(a, b, c)
        i += 12
        len -= 12
    end

    c += UInt32(length(key))
    if len == 11
        @inbounds c += key[i+10] << 24
    elseif len == 10
        @inbounds c += key[i+9] << 16
    elseif len == 9
        @inbounds c += key[i+8] << 8
    # the first byte of c is reserved for the length
    elseif len == 8
        @inbounds b += key[i+7] << 24
    elseif len == 7
        @inbounds b += key[i+6] << 16
    elseif len == 6
        @inbounds b += key[i+5] << 8
    elseif len == 5
        @inbounds b += key[i+4]
    elseif len == 4
        @inbounds a += key[i+3] << 24
    elseif len == 3
        @inbounds a += key[i+2] << 16
    elseif len == 2
        @inbounds a += key[i+1] << 8
    elseif len == 1
        @inbounds a += key[i]
    # case 0: nothing left to add
    end

    a, b, c = mix(a, b, c)
    return c
end
# typedef  unsigned long  int  ub4;   /* unsigned 4-byte quantities */typedef  unsigned       char ub1;   /* unsigned 1-byte quantities */
#
#
# </p>
# #define hashsize(n) ((ub4)1<<(n))
# #define hashmask(n) (hashsize(n)-1)
#
#
# </p>
# /* mix -- mix 3 32-bit values reversibly.
# For every delta with one or two bits set, and the deltas of all three
#   high bits or all three low bits, whether the original value of a,b,c
#   is almost all zero or is uniformly distributed,
# * If mix() is run forward or backward, at least 32 bits in a,b,c
#   have at least 1/4 probability of changing.
# * If mix() is run forward, every bit of c will change between 1/3 and
#   2/3 of the time.  (Well, 22/100 and 78/100 for some 2-bit deltas.)
# mix() takes 36 machine instructions, but only 18 cycles on a superscalar
#   machine (like a Pentium or a Sparc).  No faster mixer seems to work,
#   that's the result of my brute-force search.  There were about 2^68
#   hashes to choose from.  I only tested about a billion of those.
# */
# #define mix(a,b,c) \
# { \
#   a -= b; a -= c; a ^= (c>>13); \
#   b -= c; b -= a; b ^= (a<<8); \
#   c -= a; c -= b; c ^= (b>>13); \
#   a -= b; a -= c; a ^= (c>>12);  \
#   b -= c; b -= a; b ^= (a<<16); \
#   c -= a; c -= b; c ^= (b>>5); \
#   a -= b; a -= c; a ^= (c>>3);  \
#   b -= c; b -= a; b ^= (a<<10); \
#   c -= a; c -= b; c ^= (b>>15); \
# }
#
#
# </p>
# /* hash() -- hash a variable-length key into a 32-bit value
#   k       : the key (the unaligned variable-length array of bytes)
#   len     : the length of the key, counting by bytes
#   initval : can be any 4-byte value
# Returns a 32-bit value.  Every bit of the key affects every bit of
# the return value.  Every 1-bit and 2-bit delta achieves avalanche.
# About 6*len+35 instructions.
# The best hash table sizes are powers of 2.  There is no need to do
# mod a prime (mod is sooo slow!).  If you need less than 32 bits,
# use a bitmask.  For example, if you need only 10 bits, do
#   h = (h & hashmask(10));
# In which case, the hash table should have hashsize(10) elements.
# If you are hashing n strings (ub1 **)k, do it like this:
#   for (i=0, h=0; i<n; ++i) h = hash( k[i], len[i], h);
# By Bob Jenkins, 1996.  bob_jenkins@compuserve.com.  You may use this
# code any way you wish, private, educational, or commercial.  It's free.
# See http://ourworld.compuserve.com/homepages/bob_jenkins/evahash.htm
# Use for hash table lookup, or anything where one collision in 2^^32 is
# acceptable.  Do NOT use for cryptographic purposes.
# */
#
#
# </p>
# ub4 hash( k, length, initval)
# register ub1 *k;        /* the key */
# register ub4  length;   /* the length of the key */
# register ub4  initval;  /* the previous hash, or an arbitrary value */
# {
#    register ub4 a,b,c,len;
#
#
# </p>
#    /* Set up the internal state */
#    len = length;
#    a = b = 0x9e3779b9;  /* the golden ratio; an arbitrary value */
#    c = initval;         /* the previous hash value */
#
#
# </p>
#    /*---------------------------------------- handle most of the key */
#    while (len >= 12)
#    {
#       a += (k[0] +((ub4)k[1]<<8) +((ub4)k[2]<<16) +((ub4)k[3]<<24));
#       b += (k[4] +((ub4)k[5]<<8) +((ub4)k[6]<<16) +((ub4)k[7]<<24));
#       c += (k[8] +((ub4)k[9]<<8) +((ub4)k[10]<<16)+((ub4)k[11]<<24));
#       mix(a,b,c);
#       k += 12; len -= 12;
#    }
#    /*------------------------------------- handle the last 11 bytes */
#    c += length;
#    switch(len)              /* all the case statements fall through */
#    {
#    case 11: c+=((ub4)k[10]<<24);
#    case 10: c+=((ub4)k[9]<<16);
#    case 9 : c+=((ub4)k[8]<<8);
#       /* the first byte of c is reserved for the length */
#    case 8 : b+=((ub4)k[7]<<24);
#    case 7 : b+=((ub4)k[6]<<16);
#    case 6 : b+=((ub4)k[5]<<8);
#    case 5 : b+=k[4];
#    case 4 : a+=((ub4)k[3]<<24);
#    case 3 : a+=((ub4)k[2]<<16);
#    case 2 : a+=((ub4)k[1]<<8);
#    case 1 : a+=k[0];
#      /* case 0: nothing left to add */
#    }
#    mix(a,b,c);
#    /*-------------------------------------------- report the result */
#    return c;
# }
# Back to Article
#
# Listing Two
# /* Additive Hash */int additive(char *key, int len, int prime)
# {
#   int hash, i;
#   for (hash=len, i=0; i<len; ++i)
#     hash += key[i];
#   return (hash % prime);
# }
#
#
# </p>
# /* Rotating Hash */
# int rotating(char *key, int len, int prime)
# {
#   int hash, i;
#   for (hash=len, i=0; i<len; ++i)
#     hash = (hash<<5)^(hash>>27)^key[i];
#   return (hash % prime);
# }
#
#
# </p>
# /* Pearson's Hash */
# char pearson(char *key, int len, char tab[256])
# {
#   char hash;
#   int  i;
#   for (hash=len, i=0; i<len; ++i)
#     hash=tab[hash^key[i]];
#   return (hash);
# }
#
#
# </p>
# /* CRC Hash and Generalized CRC Hash */
# int crc(char *key, int len, int mask, int tab[256])
# {
#   int hash, i;
#   for (hash=len, i=0; i<len; ++i)
#     hash = (hash<<8)^tab[(hash>>24)^key[i]];
#   return (hash & mask);
# }
#
#
# </p>
# /* Universal Hash */
# int universal(char *key, int len, int mask, int tab[MAXBITS])
# {
#   int hash, i;
#   for (hash=len, i=0; i<(length<<3); i+=8)
#   {
#     register char k = key[i>>3];
#     if (k&0x01) hash ^= tab[i+0];
#     if (k&0x02) hash ^= tab[i+1];
#     if (k&0x04) hash ^= tab[i+2];
#     if (k&0x08) hash ^= tab[i+3];
#     if (k&0x10) hash ^= tab[i+4];
#     if (k&0x20) hash ^= tab[i+5];
#     if (k&0x40) hash ^= tab[i+6];
#     if (k&0x80) hash ^= tab[i+7];
#   }
#   return (hash & mask);
# }
#
#
# </p>
# /* Zobrist Hash */
# int zobrist( char *key, int len, int mask, int tab[MAXBYTES][256])
# {
#   int hash, i;
#   for (hash=len, i=0; i<len; ++i)
#     hash ^= tab[i][key[i]];
#   return (hash & mask);
# }
# Back to Article
#
# Listing Three
# /* Compute the Funnel-15 result for CRC */void hum()
# {
#   ub4 i,j,k,whum,x;
#   x=0x80000000;
#   whum=31;
#   for (i=0; i<(15*8); ++i)
#   {
#     x = (x & 0x80000000) ? ((x << 1) ^ 0x04c11db7) : (x << 1);
#     printf("%.8lx\n",x);
#     for (k=0, j=1; j; j=(j<<1)) if (j&x&0xff) ++k;
#     if (k<whum)
#     {
#       printf("k is %ld\n",k);
#       whum=k;
#     }
#   }
#   printf("whum is %ld %ld %ld %ld\n",whum,x,k,j);
# }
# Back to Article
#
# DDJ
#
# Copyright © 1997, Dr. Dobb's Journal
#
#
# 1 2 3 4 5 Next
# Related Reading
# News
# Commentary
# SmartBear Supports Selenium WebDriver
# Mirantis Releases Free Developer Edition
# Parasoft DevTest Shifts To Continuous
# Mac OS Installer Platform From installCore
# More News»
# Slideshow
# Video
# Jolt Awards: The Best Books
# Developer Reading List
# Developer Reading List: The Must-Have Books for JavaScript
# 2012 Jolt Awards: Mobile Tools
# More Slideshows»
# Most Popular
# RESTful Web Services: A Tutorial
# Why Build Your Java Projects with Gradle Rather than Ant or Maven?
# A Simple and Efficient FFT Implementation in C++:
# Part I
# A Gentle Introduction to OpenCL
# More Popular»
# More Insights
# White Papers
# The Forgotten Link Between Linux Threats & Cloud Security
# One Phish, Two Phish, Three Phish, Fraud Phish
# More >>
# Reports
# 2019 State of Privileged Access Management (PAM) Maturity Report
# The Future of Network Security is in the Cloud
# More >>
# Webcasts
# Cloud Security Threats Enterprises Need to Watch
# Are You Ready for When Cyber Attackers Get In?
# More >>
# INFO-LINK
#
#
# Login or Register to Comment
#
# Database Recent Articles
# Dr. Dobb's Archive
# Working with Azure DocumentDB: SQL & NoSQL Together
# Azure DocumentDB: Working with Microsoft's NoSQL Database in the Cloud
# Portability and Extensibility via Layered Product Design
# iOS Data Storage: Core Data vs. SQLite
# Most Popular
# StoriesBlogs
# Hadoop: Writing and Running Your First Project
# iOS Data Storage: Core Data vs. SQLite
# MongoDB with C#: Deep Dive
# Dr. Dobb's Archive
# JavaFX Database Programming with Java DB
# This month's Dr. Dobb's Journal
# Dr. Dobb's Digital Digest - October 2014
# This month, Dr. Dobb's Journal is devoted to mobile programming. We introduce you to Apple's new Swift programming language, discuss the perils of being the third-most-popular mobile platform, revisit SQLite on Android , and much more!
#
# Download the latest issue today. >>
#
# Upcoming Events
# Live EventsWebCasts
# March 16-19, 2020: Data Center World Registration is open! Join Us - Data Center World 2020
# Data Center World: The leading conference & expo for Data Center and IT Infrastructure Professionals. Register Today! - Data Center World 2020
# Get Insights: Cisco vs Microsoft & More at EC20 Orlando - Enterprise Connect 2020
# Featured Reports
#   What's this?
# eSentire Annual Threat Intelligence Report: 2019 Perspectives and 2020 Predictions
# The Future of Network Security is in the Cloud
# Assessing Cybersecurity Risk in Today's Enterprise
# The Definitive Guide to Managed Detection and Response (MDR)
# 2019 Threat Hunting Report
# More >>
# Featured Whitepapers
#   What's this?
# The Forgotten Link Between Linux Threats & Cloud Security
# Black Hat 2019 Hacker Survey Report
# One Phish, Two Phish, Three Phish, Fraud Phish
# eSentire Annual Threat Intelligence Report: 2019 Perspectives and 2020 Predictions
# Cybersecurity Research: 2019 AWS Cloud Security Report
# More >>
# Most Recent Premium Content
# Digital Issues
# 2014
# Dr. Dobb's Journal
# November - Mobile Development
# August - Web Development
# May - Testing
# February - Languages
#
# Dr. Dobb's Tech Digest
# DevOps
# Open Source
# Windows and .NET programming
# The Design of Messaging Middleware and 10 Tips from Tech Writers
# Parallel Array Operations in Java 8 and Android on x86: Java Native Interface and the Android Native Development Kit
#
# 2013
# January - Mobile Development
# February - Parallel Programming
# March - Windows Programming
# April - Programming Languages
# May - Web Development
# June - Database Development
# July - Testing
# August - Debugging and Defect Management
# September - Version Control
# October - DevOps
# November- Really Big Data
# December - Design
#
# 2012
# January - C & C++
# February - Parallel Programming
# March - Microsoft Technologies
# April - Mobile Development
# May - Database Programming
# June - Web Development
# July - Security
# August - ALM & Development Tools
# September - Cloud & Web Development
# October - JVM Languages
# November - Testing
# December - DevOps
#
