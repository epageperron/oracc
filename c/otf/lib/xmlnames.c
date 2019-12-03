#ifndef NULL
#define NULL (char *)0
#endif
#include "xmlnames.h"
struct nstab nstab[] = {
  { n_c, "http://oracc.org/ns/cdf/1.0" },
  { n_g, "http://oracc.org/ns/gdl/1.0" },
  { n_n, "http://oracc.org/ns/norm/1.0" },
  { n_note, "http://oracc.org/ns/note/1.0" },
  { n_syn, "http://oracc.org/ns/syntax/1.0" },
  { n_x, "http://oracc.org/ns/xtf/1.0" },
  { n_xh, "http://www.w3.org/1999/xhtml" },
  { n_xml, "http://www.w3.org/XML/1998/namespace" },
  { n_xtr, "http://oracc.org/ns/xtr/1.0" },
};

struct xname anames[] =
{
  { "xmlns:c", "xmlns:c" },
  { "xmlns:g", "xmlns:g" },
  { "xmlns:n", "xmlns:n" },
  { "xmlns:note", "xmlns:note" },
  { "xmlns:syn", "xmlns:syn" },
  { "xmlns:x", "xmlns:x" },
  { "xmlns:xh", "xmlns:xh" },
  { "xmlns:xml", "xmlns:xml" },
  { "xmlns:xtr", "xmlns:xtr" },
  { "alt", "alt" },
  { "base", "base" },
  { "class", "class" },
  { "cols", "cols" },
  { "contrefs", "contrefs" },
  { "endflag", "endflag" },
  { "ex_label", "ex_label" },
  { "extent", "extent" },
  { "flags", "flags" },
  { "form", "form" },
  { "fragid", "fragid" },
  { "from", "from" },
  { "fwhost", "fwhost" },
  { "g:accented", "http://oracc.org/ns/gdl/1.0:accented" },
  { "g:break", "http://oracc.org/ns/gdl/1.0:break" },
  { "g:breakEnd", "http://oracc.org/ns/gdl/1.0:breakEnd" },
  { "g:breakStart", "http://oracc.org/ns/gdl/1.0:breakStart" },
  { "g:c", "http://oracc.org/ns/gdl/1.0:c" },
  { "g:collated", "http://oracc.org/ns/gdl/1.0:collated" },
  { "g:damageEnd", "http://oracc.org/ns/gdl/1.0:damageEnd" },
  { "g:damageStart", "http://oracc.org/ns/gdl/1.0:damageStart" },
  { "g:delim", "http://oracc.org/ns/gdl/1.0:delim" },
  { "g:em", "http://oracc.org/ns/gdl/1.0:em" },
  { "g:hc", "http://oracc.org/ns/gdl/1.0:hc" },
  { "g:ho", "http://oracc.org/ns/gdl/1.0:ho" },
  { "g:logolang", "http://oracc.org/ns/gdl/1.0:logolang" },
  { "g:o", "http://oracc.org/ns/gdl/1.0:o" },
  { "g:pos", "http://oracc.org/ns/gdl/1.0:pos" },
  { "g:prox", "http://oracc.org/ns/gdl/1.0:prox" },
  { "g:queried", "http://oracc.org/ns/gdl/1.0:queried" },
  { "g:remarked", "http://oracc.org/ns/gdl/1.0:remarked" },
  { "g:role", "http://oracc.org/ns/gdl/1.0:role" },
  { "g:rws", "http://oracc.org/ns/gdl/1.0:rws" },
  { "g:script", "http://oracc.org/ns/gdl/1.0:script" },
  { "g:sign", "http://oracc.org/ns/gdl/1.0:sign" },
  { "g:status", "http://oracc.org/ns/gdl/1.0:status" },
  { "g:statusEnd", "http://oracc.org/ns/gdl/1.0:statusEnd" },
  { "g:statusStart", "http://oracc.org/ns/gdl/1.0:statusStart" },
  { "g:surroEnd", "http://oracc.org/ns/gdl/1.0:surroEnd" },
  { "g:surroStart", "http://oracc.org/ns/gdl/1.0:surroStart" },
  { "g:type", "http://oracc.org/ns/gdl/1.0:type" },
  { "g:uflag1", "http://oracc.org/ns/gdl/1.0:uflag1" },
  { "g:uflag2", "http://oracc.org/ns/gdl/1.0:uflag2" },
  { "g:uflag3", "http://oracc.org/ns/gdl/1.0:uflag3" },
  { "g:uflag4", "http://oracc.org/ns/gdl/1.0:uflag4" },
  { "g:utf8", "http://oracc.org/ns/gdl/1.0:utf8" },
  { "g:varc", "http://oracc.org/ns/gdl/1.0:varc" },
  { "g:vari", "http://oracc.org/ns/gdl/1.0:vari" },
  { "g:varo", "http://oracc.org/ns/gdl/1.0:varo" },
  { "guide", "guide" },
  { "hand", "hand" },
  { "haslinks", "haslinks" },
  { "headform", "headform" },
  { "headref", "headref" },
  { "hlid", "hlid" },
  { "implicit", "implicit" },
  { "l", "l" },
  { "label", "label" },
  { "lang", "lang" },
  { "lemma", "lemma" },
  { "level", "level" },
  { "lid", "lid" },
  { "morph", "morph" },
  { "n", "n" },
  { "n:num", "http://oracc.org/ns/norm/1.0:num" },
  { "norm", "norm" },
  { "note:auto", "http://oracc.org/ns/note/1.0:auto" },
  { "note:label", "http://oracc.org/ns/note/1.0:label" },
  { "note:mark", "http://oracc.org/ns/note/1.0:mark" },
  { "note:ref", "http://oracc.org/ns/note/1.0:ref" },
  { "o", "o" },
  { "p", "p" },
  { "place", "place" },
  { "plid", "plid" },
  { "pos", "pos" },
  { "primes", "primes" },
  { "project", "project" },
  { "ref", "ref" },
  { "scid", "scid" },
  { "scope", "scope" },
  { "score-mode", "score-mode" },
  { "score-type", "score-type" },
  { "score-word", "score-word" },
  { "sense", "sense" },
  { "sexified", "sexified" },
  { "sigref", "sigref" },
  { "silent", "silent" },
  { "span", "span" },
  { "spanall", "spanall" },
  { "state", "state" },
  { "strict", "strict" },
  { "subtype", "subtype" },
  { "swc-final", "swc-final" },
  { "syn:brk-after", "http://oracc.org/ns/syntax/1.0:brk-after" },
  { "syn:brk-before", "http://oracc.org/ns/syntax/1.0:brk-before" },
  { "syn:ub-after", "http://oracc.org/ns/syntax/1.0:ub-after" },
  { "syn:ub-before", "http://oracc.org/ns/syntax/1.0:ub-before" },
  { "targ-id", "targ-id" },
  { "targ-n", "targ-n" },
  { "tid", "tid" },
  { "to", "to" },
  { "type", "type" },
  { "unit", "unit" },
  { "varnum", "varnum" },
  { "xml:id", "http://www.w3.org/XML/1998/namespace:id" },
  { "xml:lang", "http://www.w3.org/XML/1998/namespace:lang" },
  { "xtr:cid", "http://oracc.org/ns/xtr/1.0:cid" },
  { "xtr:code", "http://oracc.org/ns/xtr/1.0:code" },
  { "xtr:cols", "http://oracc.org/ns/xtr/1.0:cols" },
  { "xtr:disamb", "http://oracc.org/ns/xtr/1.0:disamb" },
  { "xtr:eref", "http://oracc.org/ns/xtr/1.0:eref" },
  { "xtr:form", "http://oracc.org/ns/xtr/1.0:form" },
  { "xtr:hdr-ref", "http://oracc.org/ns/xtr/1.0:hdr-ref" },
  { "xtr:lab-end-label", "http://oracc.org/ns/xtr/1.0:lab-end-label" },
  { "xtr:lab-end-lnum", "http://oracc.org/ns/xtr/1.0:lab-end-lnum" },
  { "xtr:lab-start-label", "http://oracc.org/ns/xtr/1.0:lab-start-label" },
  { "xtr:lab-start-lnum", "http://oracc.org/ns/xtr/1.0:lab-start-lnum" },
  { "xtr:label", "http://oracc.org/ns/xtr/1.0:label" },
  { "xtr:lem", "http://oracc.org/ns/xtr/1.0:lem" },
  { "xtr:nrefs", "http://oracc.org/ns/xtr/1.0:nrefs" },
  { "xtr:overlap", "http://oracc.org/ns/xtr/1.0:overlap" },
  { "xtr:ref", "http://oracc.org/ns/xtr/1.0:ref" },
  { "xtr:refs", "http://oracc.org/ns/xtr/1.0:refs" },
  { "xtr:rend-label", "http://oracc.org/ns/xtr/1.0:rend-label" },
  { "xtr:rows", "http://oracc.org/ns/xtr/1.0:rows" },
  { "xtr:se_label", "http://oracc.org/ns/xtr/1.0:se_label" },
  { "xtr:silent", "http://oracc.org/ns/xtr/1.0:silent" },
  { "xtr:span", "http://oracc.org/ns/xtr/1.0:span" },
  { "xtr:spanall", "http://oracc.org/ns/xtr/1.0:spanall" },
  { "xtr:sref", "http://oracc.org/ns/xtr/1.0:sref" },
  { "xtr:standalone", "http://oracc.org/ns/xtr/1.0:standalone" },
  { "xtr:type", "http://oracc.org/ns/xtr/1.0:type" },
  { "xtr:unit", "http://oracc.org/ns/xtr/1.0:unit" },
  { "xtr:uref", "http://oracc.org/ns/xtr/1.0:uref" },
};
struct attr abases[] =
{
  { { anames[0].qname,NULL } , { anames[0].pname,NULL } },
  { { anames[1].qname,NULL } , { anames[1].pname,NULL } },
  { { anames[2].qname,NULL } , { anames[2].pname,NULL } },
  { { anames[3].qname,NULL } , { anames[3].pname,NULL } },
  { { anames[4].qname,NULL } , { anames[4].pname,NULL } },
  { { anames[5].qname,NULL } , { anames[5].pname,NULL } },
  { { anames[6].qname,NULL } , { anames[6].pname,NULL } },
  { { anames[7].qname,NULL } , { anames[7].pname,NULL } },
  { { anames[8].qname,NULL } , { anames[8].pname,NULL } },
  { { anames[9].qname,NULL } , { anames[9].pname,NULL } },
  { { anames[10].qname,NULL } , { anames[10].pname,NULL } },
  { { anames[11].qname,NULL } , { anames[11].pname,NULL } },
  { { anames[12].qname,NULL } , { anames[12].pname,NULL } },
  { { anames[13].qname,NULL } , { anames[13].pname,NULL } },
  { { anames[14].qname,NULL } , { anames[14].pname,NULL } },
  { { anames[15].qname,NULL } , { anames[15].pname,NULL } },
  { { anames[16].qname,NULL } , { anames[16].pname,NULL } },
  { { anames[17].qname,NULL } , { anames[17].pname,NULL } },
  { { anames[18].qname,NULL } , { anames[18].pname,NULL } },
  { { anames[19].qname,NULL } , { anames[19].pname,NULL } },
  { { anames[20].qname,NULL } , { anames[20].pname,NULL } },
  { { anames[21].qname,NULL } , { anames[21].pname,NULL } },
  { { anames[22].qname,NULL } , { anames[22].pname,NULL } },
  { { anames[23].qname,NULL } , { anames[23].pname,NULL } },
  { { anames[24].qname,NULL } , { anames[24].pname,NULL } },
  { { anames[25].qname,NULL } , { anames[25].pname,NULL } },
  { { anames[26].qname,NULL } , { anames[26].pname,NULL } },
  { { anames[27].qname,NULL } , { anames[27].pname,NULL } },
  { { anames[28].qname,NULL } , { anames[28].pname,NULL } },
  { { anames[29].qname,NULL } , { anames[29].pname,NULL } },
  { { anames[30].qname,NULL } , { anames[30].pname,NULL } },
  { { anames[31].qname,NULL } , { anames[31].pname,NULL } },
  { { anames[32].qname,NULL } , { anames[32].pname,NULL } },
  { { anames[33].qname,NULL } , { anames[33].pname,NULL } },
  { { anames[34].qname,NULL } , { anames[34].pname,NULL } },
  { { anames[35].qname,NULL } , { anames[35].pname,NULL } },
  { { anames[36].qname,NULL } , { anames[36].pname,NULL } },
  { { anames[37].qname,NULL } , { anames[37].pname,NULL } },
  { { anames[38].qname,NULL } , { anames[38].pname,NULL } },
  { { anames[39].qname,NULL } , { anames[39].pname,NULL } },
  { { anames[40].qname,NULL } , { anames[40].pname,NULL } },
  { { anames[41].qname,NULL } , { anames[41].pname,NULL } },
  { { anames[42].qname,NULL } , { anames[42].pname,NULL } },
  { { anames[43].qname,NULL } , { anames[43].pname,NULL } },
  { { anames[44].qname,NULL } , { anames[44].pname,NULL } },
  { { anames[45].qname,NULL } , { anames[45].pname,NULL } },
  { { anames[46].qname,NULL } , { anames[46].pname,NULL } },
  { { anames[47].qname,NULL } , { anames[47].pname,NULL } },
  { { anames[48].qname,NULL } , { anames[48].pname,NULL } },
  { { anames[49].qname,NULL } , { anames[49].pname,NULL } },
  { { anames[50].qname,NULL } , { anames[50].pname,NULL } },
  { { anames[51].qname,NULL } , { anames[51].pname,NULL } },
  { { anames[52].qname,NULL } , { anames[52].pname,NULL } },
  { { anames[53].qname,NULL } , { anames[53].pname,NULL } },
  { { anames[54].qname,NULL } , { anames[54].pname,NULL } },
  { { anames[55].qname,NULL } , { anames[55].pname,NULL } },
  { { anames[56].qname,NULL } , { anames[56].pname,NULL } },
  { { anames[57].qname,NULL } , { anames[57].pname,NULL } },
  { { anames[58].qname,NULL } , { anames[58].pname,NULL } },
  { { anames[59].qname,NULL } , { anames[59].pname,NULL } },
  { { anames[60].qname,NULL } , { anames[60].pname,NULL } },
  { { anames[61].qname,NULL } , { anames[61].pname,NULL } },
  { { anames[62].qname,NULL } , { anames[62].pname,NULL } },
  { { anames[63].qname,NULL } , { anames[63].pname,NULL } },
  { { anames[64].qname,NULL } , { anames[64].pname,NULL } },
  { { anames[65].qname,NULL } , { anames[65].pname,NULL } },
  { { anames[66].qname,NULL } , { anames[66].pname,NULL } },
  { { anames[67].qname,NULL } , { anames[67].pname,NULL } },
  { { anames[68].qname,NULL } , { anames[68].pname,NULL } },
  { { anames[69].qname,NULL } , { anames[69].pname,NULL } },
  { { anames[70].qname,NULL } , { anames[70].pname,NULL } },
  { { anames[71].qname,NULL } , { anames[71].pname,NULL } },
  { { anames[72].qname,NULL } , { anames[72].pname,NULL } },
  { { anames[73].qname,NULL } , { anames[73].pname,NULL } },
  { { anames[74].qname,NULL } , { anames[74].pname,NULL } },
  { { anames[75].qname,NULL } , { anames[75].pname,NULL } },
  { { anames[76].qname,NULL } , { anames[76].pname,NULL } },
  { { anames[77].qname,NULL } , { anames[77].pname,NULL } },
  { { anames[78].qname,NULL } , { anames[78].pname,NULL } },
  { { anames[79].qname,NULL } , { anames[79].pname,NULL } },
  { { anames[80].qname,NULL } , { anames[80].pname,NULL } },
  { { anames[81].qname,NULL } , { anames[81].pname,NULL } },
  { { anames[82].qname,NULL } , { anames[82].pname,NULL } },
  { { anames[83].qname,NULL } , { anames[83].pname,NULL } },
  { { anames[84].qname,NULL } , { anames[84].pname,NULL } },
  { { anames[85].qname,NULL } , { anames[85].pname,NULL } },
  { { anames[86].qname,NULL } , { anames[86].pname,NULL } },
  { { anames[87].qname,NULL } , { anames[87].pname,NULL } },
  { { anames[88].qname,NULL } , { anames[88].pname,NULL } },
  { { anames[89].qname,NULL } , { anames[89].pname,NULL } },
  { { anames[90].qname,NULL } , { anames[90].pname,NULL } },
  { { anames[91].qname,NULL } , { anames[91].pname,NULL } },
  { { anames[92].qname,NULL } , { anames[92].pname,NULL } },
  { { anames[93].qname,NULL } , { anames[93].pname,NULL } },
  { { anames[94].qname,NULL } , { anames[94].pname,NULL } },
  { { anames[95].qname,NULL } , { anames[95].pname,NULL } },
  { { anames[96].qname,NULL } , { anames[96].pname,NULL } },
  { { anames[97].qname,NULL } , { anames[97].pname,NULL } },
  { { anames[98].qname,NULL } , { anames[98].pname,NULL } },
  { { anames[99].qname,NULL } , { anames[99].pname,NULL } },
  { { anames[100].qname,NULL } , { anames[100].pname,NULL } },
  { { anames[101].qname,NULL } , { anames[101].pname,NULL } },
  { { anames[102].qname,NULL } , { anames[102].pname,NULL } },
  { { anames[103].qname,NULL } , { anames[103].pname,NULL } },
  { { anames[104].qname,NULL } , { anames[104].pname,NULL } },
  { { anames[105].qname,NULL } , { anames[105].pname,NULL } },
  { { anames[106].qname,NULL } , { anames[106].pname,NULL } },
  { { anames[107].qname,NULL } , { anames[107].pname,NULL } },
  { { anames[108].qname,NULL } , { anames[108].pname,NULL } },
  { { anames[109].qname,NULL } , { anames[109].pname,NULL } },
  { { anames[110].qname,NULL } , { anames[110].pname,NULL } },
  { { anames[111].qname,NULL } , { anames[111].pname,NULL } },
  { { anames[112].qname,NULL } , { anames[112].pname,NULL } },
  { { anames[113].qname,NULL } , { anames[113].pname,NULL } },
  { { anames[114].qname,NULL } , { anames[114].pname,NULL } },
  { { anames[115].qname,NULL } , { anames[115].pname,NULL } },
  { { anames[116].qname,NULL } , { anames[116].pname,NULL } },
  { { anames[117].qname,NULL } , { anames[117].pname,NULL } },
  { { anames[118].qname,NULL } , { anames[118].pname,NULL } },
  { { anames[119].qname,NULL } , { anames[119].pname,NULL } },
  { { anames[120].qname,NULL } , { anames[120].pname,NULL } },
  { { anames[121].qname,NULL } , { anames[121].pname,NULL } },
  { { anames[122].qname,NULL } , { anames[122].pname,NULL } },
  { { anames[123].qname,NULL } , { anames[123].pname,NULL } },
  { { anames[124].qname,NULL } , { anames[124].pname,NULL } },
  { { anames[125].qname,NULL } , { anames[125].pname,NULL } },
  { { anames[126].qname,NULL } , { anames[126].pname,NULL } },
  { { anames[127].qname,NULL } , { anames[127].pname,NULL } },
  { { anames[128].qname,NULL } , { anames[128].pname,NULL } },
  { { anames[129].qname,NULL } , { anames[129].pname,NULL } },
  { { anames[130].qname,NULL } , { anames[130].pname,NULL } },
  { { anames[131].qname,NULL } , { anames[131].pname,NULL } },
  { { anames[132].qname,NULL } , { anames[132].pname,NULL } },
  { { anames[133].qname,NULL } , { anames[133].pname,NULL } },
  { { anames[134].qname,NULL } , { anames[134].pname,NULL } },
  { { anames[135].qname,NULL } , { anames[135].pname,NULL } },
  { { anames[136].qname,NULL } , { anames[136].pname,NULL } },
  { { anames[137].qname,NULL } , { anames[137].pname,NULL } },
  { { anames[138].qname,NULL } , { anames[138].pname,NULL } },
  { { anames[139].qname,NULL } , { anames[139].pname,NULL } },
  { { anames[140].qname,NULL } , { anames[140].pname,NULL } },
  { { anames[141].qname,NULL } , { anames[141].pname,NULL } },
  { { anames[142].qname,NULL } , { anames[142].pname,NULL } },
};
struct xname enames[] =
{
  { "ag", "http://oracc.org/ns/xtf/1.0:ag" },
  { "atf", "http://oracc.org/ns/xtf/1.0:atf" },
  { "c", "http://oracc.org/ns/xtf/1.0:c" },
  { "c:bib", "http://oracc.org/ns/cdf/1.0:bib" },
  { "c:bibd", "http://oracc.org/ns/cdf/1.0:bibd" },
  { "c:bibliography", "http://oracc.org/ns/cdf/1.0:bibliography" },
  { "c:biby", "http://oracc.org/ns/cdf/1.0:biby" },
  { "c:catalog", "http://oracc.org/ns/cdf/1.0:catalog" },
  { "c:cdf", "http://oracc.org/ns/cdf/1.0:cdf" },
  { "c:document", "http://oracc.org/ns/cdf/1.0:document" },
  { "c:field", "http://oracc.org/ns/cdf/1.0:field" },
  { "c:gdl", "http://oracc.org/ns/cdf/1.0:gdl" },
  { "c:key", "http://oracc.org/ns/cdf/1.0:key" },
  { "c:p", "http://oracc.org/ns/cdf/1.0:p" },
  { "c:record", "http://oracc.org/ns/cdf/1.0:record" },
  { "c:section", "http://oracc.org/ns/cdf/1.0:section" },
  { "c:val", "http://oracc.org/ns/cdf/1.0:val" },
  { "cmt", "http://oracc.org/ns/xtf/1.0:cmt" },
  { "column", "http://oracc.org/ns/xtf/1.0:column" },
  { "composite", "http://oracc.org/ns/xtf/1.0:composite" },
  { "div", "http://oracc.org/ns/xtf/1.0:div" },
  { "e", "http://oracc.org/ns/xtf/1.0:e" },
  { "eg", "http://oracc.org/ns/xtf/1.0:eg" },
  { "f", "http://oracc.org/ns/xtf/1.0:f" },
  { "g:a", "http://oracc.org/ns/gdl/1.0:a" },
  { "g:b", "http://oracc.org/ns/gdl/1.0:b" },
  { "g:c", "http://oracc.org/ns/gdl/1.0:c" },
  { "g:d", "http://oracc.org/ns/gdl/1.0:d" },
  { "g:f", "http://oracc.org/ns/gdl/1.0:f" },
  { "g:g", "http://oracc.org/ns/gdl/1.0:g" },
  { "g:gg", "http://oracc.org/ns/gdl/1.0:gg" },
  { "g:gloss", "http://oracc.org/ns/gdl/1.0:gloss" },
  { "g:m", "http://oracc.org/ns/gdl/1.0:m" },
  { "g:n", "http://oracc.org/ns/gdl/1.0:n" },
  { "g:nonw", "http://oracc.org/ns/gdl/1.0:nonw" },
  { "g:o", "http://oracc.org/ns/gdl/1.0:o" },
  { "g:p", "http://oracc.org/ns/gdl/1.0:p" },
  { "g:q", "http://oracc.org/ns/gdl/1.0:q" },
  { "g:r", "http://oracc.org/ns/gdl/1.0:r" },
  { "g:s", "http://oracc.org/ns/gdl/1.0:s" },
  { "g:surro", "http://oracc.org/ns/gdl/1.0:surro" },
  { "g:swc", "http://oracc.org/ns/gdl/1.0:swc" },
  { "g:v", "http://oracc.org/ns/gdl/1.0:v" },
  { "g:w", "http://oracc.org/ns/gdl/1.0:w" },
  { "g:x", "http://oracc.org/ns/gdl/1.0:x" },
  { "h", "http://oracc.org/ns/xtf/1.0:h" },
  { "include", "http://oracc.org/ns/xtf/1.0:include" },
  { "l", "http://oracc.org/ns/xtf/1.0:l" },
  { "lg", "http://oracc.org/ns/xtf/1.0:lg" },
  { "m", "http://oracc.org/ns/xtf/1.0:m" },
  { "n:g", "http://oracc.org/ns/norm/1.0:g" },
  { "n:grouped-word", "http://oracc.org/ns/norm/1.0:grouped-word" },
  { "n:s", "http://oracc.org/ns/norm/1.0:s" },
  { "n:w", "http://oracc.org/ns/norm/1.0:w" },
  { "n:word-group", "http://oracc.org/ns/norm/1.0:word-group" },
  { "nong", "http://oracc.org/ns/xtf/1.0:nong" },
  { "nonl", "http://oracc.org/ns/xtf/1.0:nonl" },
  { "nonx", "http://oracc.org/ns/xtf/1.0:nonx" },
  { "note:link", "http://oracc.org/ns/note/1.0:link" },
  { "note:text", "http://oracc.org/ns/note/1.0:text" },
  { "object", "http://oracc.org/ns/xtf/1.0:object" },
  { "protocol", "http://oracc.org/ns/xtf/1.0:protocol" },
  { "protocols", "http://oracc.org/ns/xtf/1.0:protocols" },
  { "referto", "http://oracc.org/ns/xtf/1.0:referto" },
  { "score", "http://oracc.org/ns/xtf/1.0:score" },
  { "sealing", "http://oracc.org/ns/xtf/1.0:sealing" },
  { "sigdef", "http://oracc.org/ns/xtf/1.0:sigdef" },
  { "surface", "http://oracc.org/ns/xtf/1.0:surface" },
  { "surro", "http://oracc.org/ns/xtf/1.0:surro" },
  { "synopticon", "http://oracc.org/ns/xtf/1.0:synopticon" },
  { "transliteration", "http://oracc.org/ns/xtf/1.0:transliteration" },
  { "v", "http://oracc.org/ns/xtf/1.0:v" },
  { "variant", "http://oracc.org/ns/xtf/1.0:variant" },
  { "variants", "http://oracc.org/ns/xtf/1.0:variants" },
  { "xh:div", "http://www.w3.org/1999/xhtml:div" },
  { "xh:h1", "http://www.w3.org/1999/xhtml:h1" },
  { "xh:h2", "http://www.w3.org/1999/xhtml:h2" },
  { "xh:h3", "http://www.w3.org/1999/xhtml:h3" },
  { "xh:innerp", "http://www.w3.org/1999/xhtml:innerp" },
  { "xh:p", "http://www.w3.org/1999/xhtml:p" },
  { "xh:span", "http://www.w3.org/1999/xhtml:span" },
  { "xtf", "http://oracc.org/ns/xtf/1.0:xtf" },
  { "xtr:l2t", "http://oracc.org/ns/xtr/1.0:l2t" },
  { "xtr:map", "http://oracc.org/ns/xtr/1.0:map" },
  { "xtr:translation", "http://oracc.org/ns/xtr/1.0:translation" },
};
