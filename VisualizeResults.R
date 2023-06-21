library(XML)
library(ggplot2)
library(reshape2)

xdoc <- xmlTreeParse("benchmark-results.xml",useInternalNode=TRUE)
xml_data <- xmlToList(xdoc)

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="pgbench_native"]/instance')

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    bench=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(../@id)"))}),
    tps=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='tps']/@value)")))})
)
print(df)

ggplot(df, aes(x = factor(instance, levels=instance), y = tps)) +
  geom_bar(stat = "identity") +
  ylab("pgbench native (tps)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="pgbench_reference"]/instance')

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    bench=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(../@id)"))}),
    tps1=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='tps1']/@value)")))}),
    tps2=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='tps2']/@value)")))})
)
print(df)

ggplot(df, aes(x = factor(instance, levels=instance), y = tps1)) +
  geom_bar(stat = "identity") +
  ylab("pgbench reference (tps)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}


bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="timescale"]/instance')

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    bench=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(../@id)"))}),
    m1=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='csv_import']/@value)")))})
)
print(df)

ggplot(df, aes(x = factor(instance, levels=instance), y = m1)) +
  geom_bar(stat = "identity") +
  ylab("TimescaleDB CSV import (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="pg_tpch"]/instance')

if (length(bmInstances) > 0)  {
df1 <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    Q1=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query1']/@value)")))}),
    Q13=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query13']/@value)")))}),
    Q18=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query18']/@value)")))})
)

melted1 = melt(df1, id.vars="instance")
ggplot(melted1, aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-H (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

if (length(bmInstances) > 0)  {
df1 <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    Q2=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query2']/@value)")))}),
    Q3=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query3']/@value)")))}),
    Q4=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query4']/@value)")))}),
    Q5=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query5']/@value)")))}),
    Q6=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query6']/@value)")))}),
    Q7=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query7']/@value)")))})
)

melted1 = melt(df1, id.vars="instance")
ggplot(melted1, aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-H (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

if (length(bmInstances) > 0) {
df2 <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    Q8=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query8']/@value)")))}),
    Q9=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query9']/@value)")))}),
    Q10=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query10']/@value)")))}),
    Q11=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query11']/@value)")))}),
    Q12=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query12']/@value)")))}),
    Q14=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query14']/@value)")))})
)

melted2 = melt(df2, id.vars="instance")
ggplot(melted2, aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-H (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

if (length(bmInstances) > 0)  {
df3 <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    Q15=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query15']/@value)")))}),
    Q16=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query16']/@value)")))}),
    Q17=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query17']/@value)")))}),
    Q19=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query19']/@value)")))}),
    Q20=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query20']/@value)")))}),
    Q21=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query21']/@value)")))}),
    Q22=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query22']/@value)")))})
)

melted3 = melt(df3, id.vars="instance")
ggplot(melted3, aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-H (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

if (length(bmInstances) > 0)  {
df4 <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    Q100=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query100']/@value)")))}),
    Q101=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query101']/@value)")))}),
    Q102=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query102']/@value)")))})
)

melted4 = melt(df4, id.vars="instance")
ggplot(melted4, aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-H-Q1-vops (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

if (length(bmInstances) > 0)  {
df5 <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    Q600=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query600']/@value)")))}),
    Q601=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query601']/@value)")))}),
    Q602=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query602']/@value)")))}),
    Q603=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query603']/@value)")))}),
    Q604=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query604']/@value)")))})
)

melted5 = melt(df5, id.vars="instance")
ggplot(melted5, aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-H-Q6-vops (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="pg_tpcds"]/instance')
if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    load_size=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_size']/@value)")))}),
    indexes_size=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='indexes_size']/@value)")))}),
    vacuum_full_size=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='vacuum_full_size']/@value)")))}),
    vacuum_freeze_size=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='vacuum_freeze_size']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-DS (data size)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    load_time=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_time']/@value)")))}),
    indexes_time=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='indexes_time']/@value)")))}),
    vacuum_full_time=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='vacuum_full_time']/@value)")))}),
    vacuum_freeze_time=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='vacuum_freeze_time']/@value)")))}),
    analyze_time=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='analyze_time']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-DS (data prepare (sec))") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    query6=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query6']/@value)")))}),
    query72=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query72']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-DS (queries (msec))") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    query7=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query7']/@value)")))}),
    query9=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query9']/@value)")))}),
    query13=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query13']/@value)")))}),
    query28=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query28']/@value)")))}),
    query88=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query88']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-DS (queries (msec))") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    query10=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query10']/@value)")))}),
    query15=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query15']/@value)")))}),
    query16=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query16']/@value)")))}),
    query19=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query19']/@value)")))}),
    query21=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query21']/@value)")))}),
    query26=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query26']/@value)")))}),
    query34=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query34']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-DS (queries (msec))") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    query37=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query37']/@value)")))}),
    query40=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query40']/@value)")))}),
    query42=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query42']/@value)")))}),
    query43=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query43']/@value)")))}),
    query45=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query45']/@value)")))}),
    query46=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query46']/@value)")))}),
    query48=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query48']/@value)")))}),
    query50=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query50']/@value)")))}),
    query52=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query52']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-DS (queries (msec))") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}


if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    query55=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query55']/@value)")))}),
    query66=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query66']/@value)")))}),
    query68=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query68']/@value)")))}),
    query69=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query69']/@value)")))}),
    query71=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query71']/@value)")))}),
    query73=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query73']/@value)")))}),
    query76=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query76']/@value)")))}),
    query79=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query79']/@value)")))}),
    query96=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query96']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-DS (queries (msec))") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    query3=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query3']/@value)")))}),
    query82=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query82']/@value)")))}),
    query84=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query84']/@value)")))}),
    query85=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query85']/@value)")))}),
    query90=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query90']/@value)")))}),
    query91=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query91']/@value)")))}),
    query93=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query93']/@value)")))}),
    query94=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query94']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("TPC-DS (queries (msec))") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="benchmarksql_tpcc"]/instance')
if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    tpms=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='tpm_total']/@value)")))})
)
print(df)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("benchmarksql (TPM)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="ycsb"]/instance')
if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    load_a_size=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_a_size']/@value)")))}),
    load_b_size=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_b_size']/@value)")))}),
    load_c_size=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_c_size']/@value)")))}),
    load_d_size=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_d_size']/@value)")))}),
    load_f_size=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_f_size']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("YCSB (data size)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    load_a_time=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_a_time']/@value)")))}),
    load_b_time=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_b_time']/@value)")))}),
    load_c_time=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_c_time']/@value)")))}),
    load_d_time=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_d_time']/@value)")))}),
    load_f_time=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_f_time']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("YCSB (load time)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    ops_load_a_10=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_a_10_ops']/@value)")))}),
    ops_load_a_25=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_a_25_ops']/@value)")))}),
    ops_load_a_50=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_a_50_ops']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("YCSB (load 'a' throughput (ops/sec))") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    ops_load_b_10=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_b_10_ops']/@value)")))}),
    ops_load_b_25=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_b_25_ops']/@value)")))}),
    ops_load_b_50=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_b_50_ops']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("YCSB (load 'b' throughput (ops/sec))") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    ops_load_c_10=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_c_10_ops']/@value)")))}),
    ops_load_c_25=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_c_25_ops']/@value)")))}),
    ops_load_c_50=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_c_50_ops']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("YCSB (load 'c' throughput (ops/sec))") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    ops_load_d_10=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_d_10_ops']/@value)")))}),
    ops_load_d_25=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_d_25_ops']/@value)")))}),
    ops_load_d_50=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_d_50_ops']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("YCSB (load 'd' throughput (ops/sec))") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    ops_load_f_10=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_f_10_ops']/@value)")))}),
    ops_load_f_25=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_f_25_ops']/@value)")))}),
    ops_load_f_50=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_f_50_ops']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("YCSB (load 'f' throughput (ops/sec))") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="htapbench"]/instance')

if (length(bmInstances) > 0)  {
df1 <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    TPC=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='tpcc_rps']/@value)")))}),
    TPCH=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='tpch_rps']/@value)")))}),
    ClientBalancer=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='cb_rps']/@value)")))})
)

melted1 = melt(df1, id.vars="instance")
ggplot(melted1, aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("HTAPBench (req/sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="benchbase"]/instance')

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    CHbenCHmark=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='chbenchmark_rps']/@value)")))}),
    Epinions=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='epinions_rps']/@value)")))}),
    hyadapt=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='hyadapt_rps']/@value)")))}),
    OTMetrics=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='otmetrics_rps']/@value)")))}),
    SEATS=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='seats_rps']/@value)")))}),
    SIBench=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='sibench_rps']/@value)")))}),
    SmallBank=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='smallbank_rps']/@value)")))}),
    TATP=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='tatp_rps']/@value)")))}),
    Twitter=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='twitter_rps']/@value)")))}),
    Voter=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='voter_rps']/@value)")))}),
    Wikipedia=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='wikipedia_rps']/@value)")))}),
    YCSB=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='ycsb_rps']/@value)")))})
)
ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("BenchBase (ops/sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    ResourceStresser=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='resourcestresser_rps']/@value)")))}),
    TPCH=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='tpch_rps']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("BenchBase (TPCH, ResourceStresser)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    TPCC=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='tpcc_rps']/@value)")))}),
    AuctionMark=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='auctionmark_rps']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("BenchBase (TPCC, AuctionMark)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="gdprbench"]/instance')
if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    load_controller=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_controller_ops']/@value)")))}),
    load_customer=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_customer_ops']/@value)")))}),
    load_processor=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='load_processor_ops']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("GDPRbench load (ops/sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    run_controller=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='run_controller_ops']/@value)")))}),
    run_customer=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='run_customer_ops']/@value)")))}),
    run_processor=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='run_processor_ops']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("GDPRbench run (ops/sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))

}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="s64da_tpch"]/instance')
if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    total=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='total']/@value)")))}),
    query1=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query1']/@value)")))}),
    query13=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query13']/@value)")))}),
    query18=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query18']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("Swarm64 DA TPC-H (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="s64da_tpcds"]/instance')
if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    total=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='total']/@value)")))}),
    query74=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query74']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("Swarm64 DA TPC-DS (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="s64da_ssb"]/instance')
if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    query1_1=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ1.1']/@value)")))}),
    query1_2=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ1.2']/@value)")))}),
    query1_3=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ1.3']/@value)")))}),
    query2_1=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ2.1']/@value)")))}),
    query2_2=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ2.2']/@value)")))}),
    query2_3=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ2.3']/@value)")))}),
    query3_1=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ3.1']/@value)")))}),
    query3_2=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ3.2']/@value)")))}),
    query3_3=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ3.3']/@value)")))}),
    query3_4=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ3.4']/@value)")))}),
    query4_1=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ4.1']/@value)")))}),
    query4_2=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ4.2']/@value)")))}),
    query4_3=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='queryQ4.3']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("Swarm64 DA SSB (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="job"]/instance')
if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    query6b=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query6b']/@value)")))}),
    query6d=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query6d']/@value)")))}),
    query6f=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query6f']/@value)")))}),
    query7c=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query7c']/@value)")))}),
    query8a=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query8a']/@value)")))}),
    query8d=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query8d']/@value)")))}),
    query9a=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query9a']/@value)")))}),
    query9c=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query9c']/@value)")))}),
    query10c=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query10c']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("Join Order Benchmark 1 (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="job"]/instance')
if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    query11c=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query11c']/@value)")))}),
    query11d=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query11d']/@value)")))}),
    query13d=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query13d']/@value)")))}),
    query16b=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query16b']/@value)")))}),
    query17a=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query17a']/@value)")))}),
    query17b=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query17b']/@value)")))}),
    query17c=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query17c']/@value)")))}),
    query18a=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query18a']/@value)")))}),
    query18c=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query18c']/@value)")))}),
    query19a=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query19a']/@value)")))}),
    query19c=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query19c']/@value)")))}),
    query25c=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query25c']/@value)")))}),
    query28b=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query28b']/@value)")))}),
    query33a=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query33a']/@value)")))}),
    query33b=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='query33b']/@value)")))})
)

ggplot(melt(df, id.vars="instance"), aes(x = factor(instance, levels=unique(instance)), y = value, colour = variable, group = variable)) +
  geom_line() +
  ylab("Join Order Benchmark 2 (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}

bmInstances <- getNodeSet(xdoc, '/benchmarking/run/benchmark[@id="insert-1m"]/instance')

if (length(bmInstances) > 0)  {
df <- data.frame(
    instance=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(@id)"))}),
    bench=sapply(bmInstances, function(x){
        return(xpathApply(x, "string(../@id)"))}),
    time=sapply(bmInstances, function(x){
        return(as.numeric(xpathApply(x, "string(metric[@id='time']/@value)")))})
)
print(df)

ggplot(df, aes(x = factor(instance, levels=instance), y = time)) +
  geom_bar(stat = "identity") +
  ylab("1M inserts (sec)") +
  xlab("PG versions") +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
}
