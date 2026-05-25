#!/usr/bin/env python3
#usage:python ka_ks_summary.py folder_path output_file

import sys
import os
from scipy import stats
folder_path = sys.argv[1]
output_file = sys.argv[2]

dirs = os.listdir(folder_path)
with open(output_file,"w") as out:
    for dir in dirs:
        folder = folder_path +"/" + dir
        if os.path.isdir(folder):
            paml_result_model4a = folder +"/"+ "/PAML_output_model4a.txt"
            paml_result_model0 = folder +"/"+ "/PAML_output_model0.txt"
            genelist = dir
            with open(paml_result_model4a,"r") as input_paml, open(paml_result_model0,"r") as input_paml_model0:
                ds_tree = ""
                dn_tree = ""
                model0_freedom = ""
                model0_lnl = ""
                model4a_freedom = ""
                model4a_lnl = ""
                w_origintree = ""
#calculate p_value
                for line in input_paml_model0:
                    if line.startswith("lnL"):
                        lnl = line
                        lnl_list = lnl.split()
                        model0_freedom = float(lnl_list[3].rstrip("):"))
                        model0_lnl = float(lnl_list[4])
                        print("model0: ", model0_freedom, model0_lnl)
                for line in input_paml:
                    if line.startswith("lnL"):
                        lnl = line
                        lnl_list = lnl.split()
                        model4a_freedom = float(lnl_list[3].rstrip("):"))
                        model4a_lnl = float(lnl_list[4])
                        print("model4a: ", model4a_freedom, model4a_lnl)
                    if line.startswith("w ratios as node labels:"):
                        w_origintree = input_paml.readline()  #get w_origin    
                    if line.startswith("dS tree:"):
                        ds_tree = input_paml.readline()       #get dS
                        ds_tree_detail = ds_tree.split()
                        for i in range(len(ds_tree_detail)):
                            if ds_tree_detail[i].endswith(":"):
                                if ds_tree_detail[i+1].endswith("):"):
                                    ds_tree_detail[i+1] = str(float(ds_tree_detail[i+1].rstrip("):"))+1) + "):"
                                elif ds_tree_detail[i+1].endswith(","):
                                    ds_tree_detail[i+1] = str(float(ds_tree_detail[i+1].rstrip(","))+1) + ","
                                elif ds_tree_detail[i+1].endswith(");"):
                                    ds_tree_detail[i+1] = str(float(ds_tree_detail[i+1].rstrip(");"))+1) + ");"        #给dS+1
                    if line.startswith("dN tree:"):
                        dn_tree = input_paml.readline()       #get dN
                        dn_tree_detail = dn_tree.split()
                        for i in range(len(dn_tree_detail)):
                            if dn_tree_detail[i].endswith(":"):
                                if dn_tree_detail[i + 1].endswith("):"):
                                    dn_tree_detail[i + 1] = str(float(dn_tree_detail[i + 1].rstrip("):")) + 1) + "):"
                                elif dn_tree_detail[i + 1].endswith(","):
                                    dn_tree_detail[i + 1] = str(float(dn_tree_detail[i + 1].rstrip(",")) + 1) + ","
                                elif dn_tree_detail[i + 1].endswith(");"):
                                    dn_tree_detail[i + 1] = str(float(dn_tree_detail[i + 1].rstrip(");")) + 1) + ");"  #给dN+1
                        w_ratio_detail = dn_tree_detail
                        for i in range(len(dn_tree_detail)):
                            if w_ratio_detail[i].endswith(":"):
                                if w_ratio_detail[i + 1].endswith("):"):
                                    w_ratio_detail[i + 1] = str((float(dn_tree_detail[i + 1].rstrip("):")))/(float(ds_tree_detail[i + 1].rstrip("):")))) + "):"
                                elif w_ratio_detail[i + 1].endswith(","):
                                    w_ratio_detail[i + 1] = str((float(dn_tree_detail[i + 1].rstrip(",")))/(float(ds_tree_detail[i + 1].rstrip(",")))) + ","
                                elif w_ratio_detail[i + 1].endswith(");"):
                                    w_ratio_detail[i + 1] = str((float(dn_tree_detail[i + 1].rstrip(");")))/(float(ds_tree_detail[i + 1].rstrip(");")))) + ");"      #计算dN+1/dS+1
                        w_ratio_tree = " ".join(w_ratio_detail)
                print(genelist)
                if isinstance(model4a_lnl,float):
                    p_value = 1-stats.chi2.cdf((float(model4a_lnl) - float(model0_lnl))*2,float(model4a_freedom)-float(model0_freedom))   # 卡方检验
                    result = genelist + "\t" + dn_tree.rstrip("\n") + "\t" + ds_tree.rstrip("\n") + "\t" + w_origintree.rstrip("\n") + "\t" + w_ratio_tree +"\t" + str(model4a_lnl) +"\t" +str(model0_lnl)+"\t" + str(model4a_freedom) +"\t"+str(model0_freedom) +"\t" +str(p_value) +"\n"
                else:
                    result = genelist + "\t" + "PAML_no_result"+"\n"
                out.write(result)
            input_paml.close()
out.close()




