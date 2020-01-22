### Creating a dataset of ECB legal acts from EUR-Lex. Last updated: January 2020.

# Load the libraries and functions
source ('./00 libraries and functions.R')

# Read the file with urls (the file is sent from EUR-Lex after a search for all legal acts with the ECB as an author and then exported)
url.file<-read.csv('./Search results 20200116.csv')
urls<-paste0("http://eur-lex.europa.eu/legal-content/EN/ALL/?uri=CELEX:",url.file$CELEX.number)

# Download the files
for (i in 1: length(urls)){
  if (url.exists(urls[i], .header=TRUE)['statusMessage']=='Not Found')
    print (urls[i])
  #next
  else
    download.file(urls[i], destfile=paste0("./legal_acts/",
                                           str_replace_all(urls[i], "http://eur-lex.europa.eu/legal-content/EN/ALL/\\?uri=CELEX:", ""),
                                           ".html"), 
                  method='libcurl', mode='w', cacheOK=TRUE, quiet=T, Sys.sleep(1))
}  

### Identify the files
docs <- list.files(path= './legal_acts/', pattern = "*.html", full.names=TRUE, recursive=TRUE)  

### Prepare the outfile
# specify column names
colnames_out<-c('celex', 'title', 'language', 'type', 'form','date_doc','author',  'addressee',
                'eurovoc', 'subject', 'dir_code', 'legal_bases','treaty','instr_cited',
                'amendments_all', 'amendments_1','amendments_2','amendments_3','amendments_4','amendments_5','amendments_6',
                'test_date1','test_date2','test_date3','test_date4','test_date5','all_dates',
                'title_from_text','lang_from_text','date_from_text','oj_reference','full_text','art_numbers','art_titles','text_notes','text_signature','text_bottom',
                'text_normal','text_italic','text_bold','text_tables',
                'celex1', 'title1', 'type1','date_doc1','author1','changes','in_force', 'date_pub', 'date_force', 'date_expiration', 'keywords', 'legal_basis1'
                )
# prepare the output data frame
out<-data.frame(matrix(NA, nrow=length(docs), ncol=length(colnames_out)))
colnames(out)=colnames_out

### Extract the variables from the files
for (i in 1:length(docs)){
  h<-read_html(docs[i], encoding='UTF-8') #read the file
  
  # Basic information
  
  #this block gets info from the general meta tags and from classes
  get_content('title', '//meta[@name="WT.z_docTitle"]/@content') 
  get_content('celex', '//meta[@name="WT.z_docID"]/@content') 
  get_content('type', '//meta[@name="WT.z_docType"]/@content') 
  
  get_content('form', '//*[contains(concat( " ", @class, " " ), concat( " ", "NMetadata", " " ))]//dt[.="Form: "]/following-sibling::dd[1]') 
  get_content('author', '//*[contains(concat( " ", @class, " " ), concat( " ", "NMetadata", " " ))]//dt[.="Author: "]/following-sibling::dd[1]') 
  get_content('addressee', '//*[contains(concat( " ", @class, " " ), concat( " ", "NMetadata", " " ))]//dt[.="Addressee: "]/following-sibling::dd[1]') 
  get_content('language', '//*[contains(concat( " ", @class, " " ), concat( " ", "panel-body", " " ))]/@lang') 
  get_content('eurovoc', '//*[contains(concat( " ", @class, " " ), concat( " ", "NMetadata", " " ))]//dt[.="EUROVOC descriptor: "]/following-sibling::dd[1]/ul/li') 
  get_content('subject', '//*[contains(concat( " ", @class, " " ), concat( " ", "NMetadata", " " ))]//dt[.="Subject matter: "]/following-sibling::dd[1]/ul/li') 
  get_content('dir_code', '//*[contains(concat( " ", @class, " " ), concat( " ", "NMetadata", " " ))]//dt[.="Directory code: "]/following-sibling::dd[1]/ul/li') 
  get_content('date_doc', '//*[contains(concat( " ", @class, " " ), concat( " ", "NMetadata", " " ))]//dt[.="Date of document: "]/following-sibling::dd'[1]) 
  
  get_content('treaty', '//*[contains(concat( " ", @id, " " ), concat( " ", "PPLinked_Contents", " " ))]//dt[.="Treaty: "]/following-sibling::dd[1]') 
  get_content('legal_bases', '//*[contains(concat( " ", @id, " " ), concat( " ", "PPLinked_Contents", " " ))]//dt[.="Legal basis: "]/following-sibling::dd[1]/ul/li') 
  get_content('instr_cited', '//*[contains(concat( " ", @id, " " ), concat( " ", "PPLinked_Contents", " " ))]//dt[.="Instruments cited: "]/following-sibling::dd[1]') 
  get_content('amendments_all', '//*[contains(concat( " ", @id, " " ), concat( " ", "PPLinked_Contents", " " ))]//dt[.="Amendment to: "]/following-sibling::dd//tr') 
  
  get_content('all_dates', '//*[contains(concat( " ", @id, " " ), concat( " ", "PPDates_Contents", " " ))]') 
  
  get_content('full_text', '//*[contains(concat( " ", @id, " " ), concat( " ", "PP4Contents", " " ))]') 
  
  get_content('title_from_text', '//*[contains(concat( " ", @class, " " ), concat( " ", "doc-ti", " " ))]') 
  get_content('lang_from_text', '//*[contains(concat( " ", @class, " " ), concat( " ", "hd-lg", " " ))]') 
  get_content('date_from_text', '//*[contains(concat( " ", @class, " " ), concat( " ", "hd-date", " " ))]') 
  get_content('oj_reference', '//*[contains(concat( " ", @class, " " ), concat( " ", "hd-oj", " " ))]') 
  get_content('art_numbers', '//*[contains(concat( " ", @class, " " ), concat( " ", "ti-art", " " ))]') 
  get_content('art_titles', '//*[contains(concat( " ", @class, " " ), concat( " ", "sti-art", " " ))]') 
  get_content('text_notes', '//*[contains(concat( " ", @class, " " ), concat( " ", "note", " " ))]') 
  get_content('text_signature', '//*[contains(concat( " ", @class, " " ), concat( " ", "signatory", " " ))]') 
  get_content('text_bottom', '//*[contains(concat( " ", @class, " " ), concat( " ", "final", " " ))]') 
  get_content('text_normal', '//*[contains(concat( " ", @class, " " ), concat( " ", "normal", " " ))]') 
  get_content('text_italic', '//*[contains(concat( " ", @class, " " ), concat( " ", "italic", " " ))]') 
  get_content('text_bold', '//*[contains(concat( " ", @class, " " ), concat( " ", "bold", " " ))]') 
  get_content('text_tables', '//*[contains(concat( " ", @class, " " ), concat( " ", "tbl-txt", " " ))]') 
  
  #this block gets infor from the ELI meta tags
  get_content('celex1', '//meta[@property="eli:id_local"]/@content') 
  get_content('title1', '//meta[@lang="en"][@property="eli:title"]/@content')
  get_content('type1', '//meta[@property="eli:type_document"]/@resource')
  get_content('author1', '//meta[@property="eli:passed_by"]/@resource')
  get_content('changes', '//meta[@property="eli:changes"]/@resource')
  get_content('in_force', '//meta[@property="eli:in_force"]/@resource')
  # dates
  get_content('date_doc1', '//meta[@property="eli:date_document"]/@content')
  get_content('date_pub', '//meta[@property="eli:date_publication"]/@content')
  get_content('date_force', '//meta[@property="eli:first_date_entry_in_force"]/@content')
  get_content('date_expiration', '//meta[@property="eli:date_no_longer_in_force"]/@content')
  # descriptors
  get_content('keywords', '//meta[@property="eli:is_about"]/@resource')
  get_content('legal_basis1', '//meta[@property="eli:based_on"]/@resource')
  
}

# Save the result
write.csv(out, './output_tables/all_ecb_acts_raw.csv')
write.xlsx(out, './output_tables/all_ecb_acts_raw.xlsx')
save(out, file='./output_tables/all_ecb_acts_raw.Rdata')

# Variable transformations I
out2 <- out %>%
  mutate(corrigendum = ifelse (str_detect(form, 'Corrigendum')==TRUE, 1, 0),
         form_nocor = str_replace(form, '\\s*Corrigendum\\s*', ''),
         form2 = recode(form_nocor, 'Interinstitutional agreement'='Rules of procedure','Internal agreement'='Rules of procedure', 'Rules of procedure Rules of procedure'='Rules of procedure'),
         date_doc = as.Date(substr(date_doc,1,10), format= '%d/%m/%Y'),
         dir_code = str_replace_all(dir_code, "\n|\r|\t|\  ", ""),
         instr_cited = str_replace_all(instr_cited, "\n|\r|\t|\  ", ""),
         all_dates = str_replace_all(all_dates, "\n|\r|\t|\  ", " "),
         all_dates = str_replace_all(all_dates, "\\s+", " "),
         full_text = str_replace_all(full_text, "\n|\r|\t|\  ", ""),
         full_text_chars = nchar (full_text),
         full_text_words = str_count(full_text, "\\S+"),
         annex_pos = str_locate(full_text, 'ANNEX I')[,1],
         in_force = gsub('http://data.europa.eu/eli/ontology#InForce-', '', in_force),
         amendments_all = str_replace_all(amendments_all, "\n|\r|\t|\   ", ""),
         amendments_all = str_replace_all(amendments_all, "RelationActCommentSubdivision concernedFromTo; ", ""),
         corrigendum2 = str_detect(amendments_all, 'Corrigendum to'),
         repealed = str_detect(amendments_all, paste(c('Repealed by', 'repealed by'), collapse="|")),
         repeals = str_detect(amendments_all, paste(c('Repeal ', 'repeal '), collapse="|")),
         amendedby = str_detect(amendments_all, paste(c('Amended by', 'amended by'), collapse="|")),
         amends = str_detect(amendments_all, paste(c('Amendment', 'amendment'), collapse="|")),
         amendsrepeals = ifelse(amends==TRUE | repeals==TRUE, 1 ,0),
         recast = str_detect(title, paste(c('Recast', 'recast'), collapse="|")),
         date_doc2 = as.Date(substr(all_dates, str_locate(all_dates, 'Date of document: ')[,2]+1, str_locate(all_dates, 'Date of document: ')[,2]+10),'%d/%m/%Y'),
         date_effect = as.Date(substr(all_dates, str_locate(all_dates, 'Date of effect: ')[,2]+1, str_locate(all_dates, 'Date of effect: ')[,2]+10),'%d/%m/%Y'),
         date_end = as.Date(substr(all_dates, str_locate(all_dates, 'Date of end of validity: ')[,2]+1, str_locate(all_dates, 'Date of end of validity: ')[,2]+10),'%d/%m/%Y'),
         reason_end = substr(all_dates, str_locate(all_dates, 'Date of end of validity: ')[,2]+13, nchar(all_dates)),
         in_force2 = ifelse (in_force=='notInForce' | date_end!='9999-12-31', 'notinforce', 'inforce'),
         in_force2 = ifelse (is.na(in_force2) & date_end=='9999-12-31', 'inforce', in_force2),
         in_force2 = ifelse (in_force2=='inforce' & (repealed==FALSE | is.na(repealed)) , in_force2, 'notinforce'),
         in_force2 = ifelse (is.na(in_force2) & corrigendum==0, 'inforce', in_force2),
         year = year(date_doc),
         semester = semester(date_doc),
         year.sem = paste0(year, '.', semester)
         )

# Variable transformations II (unpack fields with multiple values)
out2 <- out2 %>%  
  separate (eurovoc, sep="; ", into=paste0('eurovoc.',1:max(lengths(str_split(out$eurovoc, '; ')))), fill='right', remove=FALSE) %>%
  separate (subject, sep="; ", into=paste0('subject.',1:max(lengths(str_split(out$subject, '; ')))), fill='right', remove=FALSE) %>%
  separate (dir_code, sep="; ", into=paste0('dir_code.',1:max(lengths(str_split(out$dir_code, '; ')))), fill='right', remove=FALSE) %>%
  separate (legal_bases, sep="; ", into=paste0('legal_basis.',1:max(lengths(str_split(out$legal_bases, '; ')))), fill='right', remove=FALSE) %>%
  separate (instr_cited, sep=" ", into=paste0('instr_cited.',1:max(lengths(str_split(out$instr_cited, ' ')))), fill='right', remove=FALSE) %>%
  #separate (amendments_all, sep="; ", into=paste0('amendments_all.',1:max(lengths(str_split(out$amendments_all, '; ')))), fill='right', remove=FALSE) %>% 
  
  mutate(dir_code.1.short = substr(dir_code.1, 1, 11), 
         dir_code.2.short = substr(dir_code.2, 1, 11), 
         dir_code.3.short = substr(dir_code.3, 1, 11), 
         dir_code.4.short = substr(dir_code.4, 1, 11), 
         dir_code.1.short.main = substr(dir_code.1, 1, 2), 
         dir_code.2.short.main = substr(dir_code.2, 1, 2), 
         dir_code.3.short.main = substr(dir_code.3, 1, 2), 
         dir_code.4.short.main = substr(dir_code.4, 1, 2)
        )

# Save the result
write.csv(out2, './output_tables/all_ecb_acts_edited.csv')
write.xlsx(out2, './output_tables/all_ecb_acts_edited.xlsx')
save(out2, file='./output_tables/all_ecb_acts_edited.Rdata')

# load('./output_tables/all_ecb_acts_edited.Rdata') #load the table

# Filter variables and some values based on author
out3<-out2 %>% 
  filter (corrigendum==0)

# Save the result without corrigenda
write.csv(out3, './output_tables/all_ecb_acts_edited_nocor.csv')
write.xlsx(out3, './output_tables/all_ecb_acts_edited_nocor.xlsx')
save(out3, file='./output_tables/all_ecb_acts_edited_nocor.Rdata')

# Select only the most important variables
out4<-out3 %>% 
  select (celex, date_doc, year, year.sem, form2, in_force2, date_end, full_text_words, title)

# Save the short result without corrigenda
write.csv(out4, './output_tables/all_ecb_acts_edited_nocor_short.csv')
write.xlsx(out4, './output_tables/all_ecb_acts_edited_nocor_short.xlsx')
save(out4, file='./output_tables/all_ecb_acts_edited_nocor_short.Rdata')

### Some tabular overviews
kable(table(out3$form2, out3$in_force2)) #number of legal acts per legal form and whether in force or not
kable(table(out3$year.sem, out3$form2)) #number of legal acts adopted per legal form per semester
kable(group_by(out4, year) %>% summarise(number.words = sum(full_text_words, na.rm=T))) #number of words of adopted legal acts per year

### Some simple graphs
temp2<-table(out4$form2, out4$year)
#temp2<-prop.table(temp2,2)

p <- plot_ly(data.frame(temp2), x = ~colnames(temp2), y = ~temp2[1,], type = 'bar', name = 'Decisions') %>%
  add_trace(y = ~temp2[2,], name = 'Guidelines') %>%
  add_trace(y = ~temp2[5,], name = 'Regulations') %>%
  add_trace(y = ~temp2[3,], name = 'Opinions') %>%
  add_trace(y = ~temp2[4,], name = 'International agreements') %>%
  add_trace(y = ~temp2[6,], name = 'Rules of procedure') %>%
  layout(title = 'Number of legal acts adopted by the European Central Bank',
         #titlefont = list(size = 22),
         yaxis = list(title = 'Number of legal act'), 
         xaxis = list(title = ''),
         barmode = 'stack',
         legend = list(x = 0.05, y = 0.88, bgcolor = 'rgba(255, 255, 255, 0)', bordercolor = 'rgba(255, 255, 255, 0)'))
p

temp<-table(out4$form2[out4$in_force=='inforce'])

p2 <- plot_ly(data.frame(temp), labels = ~names(temp), values = temp, type = 'pie',
              textposition = 'inside',
              textinfo = 'label+percent',
              insidetextfont = list(color = '#FFFFFF'),
              showlegend = FALSE) %>%
  layout(title = 'Types of European Central Bank legal acts in force in 2020',
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
p2

temp3<-table(out4$year)
#temp2<-prop.table(temp2,2)

p3 <- plot_ly(data.frame(temp3), x = ~names(temp3), y = ~temp3, type = 'bar', name = 'Legal acts',
              text = temp3, textposition = 'auto') %>%
    layout(title = 'Number of legal acts adopted by the European Central Bank',
         #titlefont = list(size = 22),
         yaxis = list(title = 'Number of legal act'), 
         xaxis = list(title = ''))
p3


### Checks and tests
#check missing in the table but present in folder
urls1<-str_replace_all(urls, "http://eur-lex.europa.eu/legal-content/EN/ALL/\\?uri=CELEX:", "")
setdiff(urls1, out$celex)
setdiff(out$celex, urls1)

#tests
url = paste0('http://eur-lex.europa.eu/legal-content/EN/ALL/?uri=CELEX:', setdiff(urls1, out$celex)[1]) 
h<-read_html(url, encoding='UTF-8') #read the file
h1<-html_nodes(h, 'body')
h2<-html_text(html_nodes(h, 'body'))

url2 = paste0('http://eur-lex.europa.eu/legal-content/EN/ALL/?uri=CELEX:', '32003R1746') 
z<-read_html(url2, encoding='UTF-8') #read the file
z1<-html_nodes(z, 'body')
z2<-html_text(html_nodes(z, 'body'))

x=html_nodes(z,xpath = '//*[contains(concat( " ", @id, " " ), concat( " ", "PPLinked_Contents", " " ))]//dt[.="Amendment to: "]/following-sibling::dd//tr')
x=html_nodes(z,xpath = '//*[contains(concat( " ", @id, " " ), concat( " ", "PPDates_Contents", " " ))]')
x=html_text(x)
x=str_replace_all(x, "\n|\r|\t|\   ", " ")
x=str_replace_all(x, "   ", " ")



