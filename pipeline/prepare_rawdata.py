#!/usr/bin/python

import sys
import os
import StringIO
from subprocess import Popen,PIPE

TYPE_EXP_UNSTRAND=1
TYPE_EXP_STRAND_DUTP=2
TYPE_EXP_STRAND_LIGATION=3

class FastQ :
    def __init__(self,full_path) :
        path,fn=os.path.split(full_path)
        self._fn=fn
        self._path=path
        self._full_path=full_path
        self._unit_s=self._fn.split("_")
    def __eq__(self,other) :
        if other==None :
            return False
        if not isinstance(other,FastQ) :
            return False
        if self._full_path!=other._full_path :
            return False
        return True
    def __cmp__(self,other) :
        if other==None :
            return -1
        if self._full_path > other._full_path :
            return 1
        if self._full_path < other._full_path :
            return -1
        return 0
    def __str__(self) :
        return self._fn
    def is_formal(self):
        if len(self._unit_s)<4 :
            return False
        return True
    def id(self):
        return self._unit_s[0]
    def tag(self):
        return self._unit_s[1]
    def lane(self):
        return self._unit_s[2]
    def read(self):
        return self._unit_s[3]
    def full(self):
        return self._full_path

class FastQGroup :
    def __init__(self,id):
        self._id=id
        self._r1_fq_s=[]
        self._r2_fq_s=[]
    def id(self):
        return self._id
    def add(self,one) :
        if one.read()=='R1' :
            self._r1_fq_s.append(one)
        elif one.read()=='R2' :
            self._r2_fq_s.append(one)
    def sort(self) :
        self._r1_fq_s.sort()
        self._r2_fq_s.sort()
    def fn_1(self) :
        fn_1="Raw/%s_1.fq.gz"%self.id()
        return fn_1
    def fn_2(self) :
        fn_2="Raw/%s_2.fq.gz"%self.id()
        return fn_2
    def sh_merge(self):
        buf_1=[]
        buf_2=[]
        for i_fq in range(len(self._r1_fq_s)) :
            buf_1.append(self._r1_fq_s[i_fq].full())
            buf_2.append(self._r2_fq_s[i_fq].full())
        return " ".join(buf_1), " ".join(buf_2)

def read(input_path) :
    cmd=[]
    cmd.append("find")
    cmd.append("-L")
    cmd.append(input_path)

    #print " ".join(cmd)

    p=Popen(cmd,stdout=PIPE,stderr=PIPE)
    out,err=p.communicate()

    fn_s=[]
    for line in StringIO.StringIO(out) :
        line=line.strip()
        #print "Checking %s"%line
        if not ( line.endswith(".fq") \
                or line.endswith(".fq.gz") \
                or line.endswith(".fastq") \
                or line.endswith(".fastq.gz") ) :
            continue
        fn_s.append(FastQ(line.strip()))
    fn_s.sort()
    return fn_s

def usage() :
    print " Rine Preparation v3 (2013-11-27)"
    print """    %s [PROJECT_HOME] [Raw PATH]"""%(os.path.split(__file__)[1])

def main() :
    if len(sys.argv)<3 :
        usage()
        return

    project_path=os.path.abspath(sys.argv[1])
    input_path=os.path.abspath(sys.argv[2])
    #
    fn_s=read(input_path)
    #
    fq_s={}
    for fn in fn_s :
        if not fn.is_formal() :
            continue
        if fn.id() not in fq_s.keys() :
            fq_group=FastQGroup(fn.id())
            fq_group.add(fn)
            fq_s[fn.id()]=fq_group
        else :
            fq_s[fn.id()].add(fn)
    #
    id_s=fq_s.keys()
    id_s.sort()
    #
    out=file("merge.sh",'wt')
    out.write("mkdir Raw\n")
    for id in id_s :
        fq_group=fq_s[id]
        fq_group.sort()
        fq_group.id()
        merge_1, merge_2 = fq_group.sh_merge()
        out.write("# %s\n"%(fq_group.id()))
        out.write("cat %s > Raw/%s_1.fq.gz\n"%(merge_1,fq_group.id()))
        out.write("cat %s > Raw/%s_2.fq.gz\n"%(merge_2,fq_group.id()))
        out.write("\n")
    out.close()
    #

if __name__=='__main__' :
    main()

