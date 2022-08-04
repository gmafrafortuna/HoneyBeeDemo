include: ancestral_inference.smk
include: multiple_genome_alignment.smk
include: qc_vcf.smk

configfile: "config/tsinfer.yaml"

rule match_ancestral_vcf:
    input:
        vcfPos=config['vcfPos'] # This has more lines
        ancestralAllele=config['ancestralAllele']
    output:
        "Tsinfer/AncestralVcfMatch.txt"
    shell:
    """
    for line in $(cat {input.vcf}});
    do
      grep $line {input.ancestralAllele} || echo "";
    done
    """

rule change_infoAA_vcf:
    input:
        vcf=config['vcf']
        ancestralAllele="Tsinfer/AncestralVcfMatch.txt"
    output:
        "Tsinfer/Vcf_AncestralInfo.vcf"
    shell:
        """
        NUM=$(( $(grep "##" {input.vcf} | wc -l) + 1 ))
        awk -v NUM=$NUM 'NR==FNR{a[NR] = $2; next} FNR<29{print}; \
        FNR==5{printf "##INFO=<ID=AA,Number=1,Type=String,Description=\"Ancestral Allele\">\n"}; \
        FNR>28{$8=a[FNR-28]; print}' OFS="\t" All_AAInfo.txt test.vcf awk '{FNR>28{print a[FNR-28]}}' \
        {input.ancestralAllele} {input.vcf} > {output}
        """

rule prepare_sample_file:
    input:
        vcf=
        meta=
    output:
