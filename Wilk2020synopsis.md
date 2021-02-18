## A single-cell atlas of the peripheral immune response in patients with severe COVID-19

1. Отсеквенировали РНК крови (а конкретнее - _PBMC - peripheral blood mononuclear cell_ - т.е. лимфоциты, моноциты и дендритные клетки; которые выделили центрифугированием и потом провернули ПЦР с обратной транскрипцией) порядка 13 людей (6 человек контроля, по несколько человек  с серьёзным (ARDS - acute respiratory distress syndrome) и не очень ковидом) - scRNA с использованием платформы Seq-Well.

2. Выравнили на геном человека с помощью _STAR_ - выравнивателя, заточенного под RNA. "No SARS-CoV-2 reads were aligned from these samples using this strategy" ... 

3. Подсчитали count matrices ("gene counts per sample") по полученным BAM-файлам - _dropEst_ 

4. Удалили клетки, в которых UMIs слишком маленькое ( < 1000) или слишком большое ( > 15000), а также те, в которых было больше 20% ридов с митохондрий или рРНК. И те, в которых экспрессировалось больше 75 генов на 100 UMIs. __Также__ не рассматривали гены, которые экспрессировались менее чем в 10 клетках.

### Предварительная обработка

1. Сделали матрицу Клетки х Гены
2. Понизили размерность (выделили 50 главных компонент и к ним применили UMAP - хитрое нелинейное сжатие) и применили графовый алгоритм кластеризации - получилось 30 кластеров
3. В кластерах посмотрели на гены с самой сильной экспрессией (most highly deferentially expressed - DE) и по этим генам определи, к какому типу клеток относятся кластеры. 
	_Обнаружились различия в фенотипе между пациентами с ковидом и контрольной группой, особенно в моноцитах, Т клетках и NK клетках_.
	
Затем они дали количественную оценку вызванным Ковидом изменениям в пропорциях типов клеток... У больных было снижена (depleted) доля нескольких типов имунных клеток: 
1) $\gamma \delta\ T$-клетки 
2) плазмоцитоидные дендритные клетки (pDCs)
3) CD16+ моноциты
4) NK-клетки
(для 2-4 значимое различие наблюдалось только для больных на вентиляции)

Ещё у больных выше доля плазмобластов (клеток плазмы?), "suggesting that more severe cases may be associated with a more _robust humoral immune response_". При этом в них (клетках) не обнаружились гены V-иммуноглобулина.

Также у больных на вентиляции была самая многочисленная популяция новых клеток, которую назвали _developing neutrophils_. Эти клетки экспрессируют гены, кодирующие " neutrophil granule proteins" (LANE, LTF, MMP8), но не экспрессируют гены маркеров нейтрофиллов (FCGR3B, CXCR2), а при проецировании UMAP-ом расположены ближе к плазмобластам, чем к "каноничным нейтрофилам".
Среди этих новых клеток также экспрессируются CEACAM8, ELANE, LYZ - те же гены, что и у предков (_progenitors_) нейтрофиллов.
Поэтому предположили, что эти новые клетки суть различные стадии развития нейтрофилов.

---
### Анализ моноцитов.
- ведь конкретно моноциты сильно отличаются у пациентов от контоля:

8 генов, кодирующих молекулы класса HLA II, даунрегулированы (???) (особенно это проявляется у больных на вентиляции).
Эта даунрегуляция "is reflected in differentially regulated gene pathways including reduction of crosstalk between dendritic cells and natural killer cells"
Также эта даунрегуляция замечена в В-клетках. И она в целом сильнее у более старых пациентов.

"Additionally, 32 interferon (IFN)-stimulated genes (ISGs) were upregulated by CD14+ monocytes in at least one COVID-19 sample, but this IFN signature was not uniform across all COVID-19 samples" - __круто конечно, но блин, рандом же.__
" The differential ISG signature was not explained by ventilation or ARDS, but a higher ISG score trended towards a positive correlation with age and a negative correlation with time–distance from fever onset"

### Анализ Т и NK лимфоцитов

* CD56dim NK (cell-mediated cytotoxicity) - depleted в больних с ОРДС
*  CD56bright NK (robust producers of IFN-γ and tumor necrosis factor α) - depleted во всех больных.
*  Обнаружился кластер пролиферативных лимфоцитов - их больше во всех больных

Короновирус ассоциируется  с истощением лимфоцитов, потому ребята решили проверить экспрессию генов, кодирующих маркеры истощения... и не нашли значимого увеличения экспрессии.

А вот NK-клетки истощены (судя по экспрессии маркеров (LAG3, PDCD1, HAVCR2). 
Экспрессию воспалительных цитокинов не обнаружили ни в Т и NK клетках, ни в моноцитах. "This again indicates that transcription of pro-inflammatory cytokines by peripheral leukocytes is unlikely to be a major contributor to the putative cytokine storm in COVID-19." __wtf__

### Pathways
Посмотрели на (наиболее сильно?) дифференциально экспрессируемые гены в Т и NK клетках, сравнили их экспрессию с контролем, и по ним определели enriched gene pathways и upstream regulators. 
В __НК клетках__:
* даунрегуляция:  гены, кот. ассоциируются с созреванием переферийных НК клеток (FCGR3A, AHNAK and FGFBP2)
* апрегуляция: ISGs (гены, стимулируемые интерфероном и гены активации NK клеток)... ...стоп, так NK клетки же истощены? или это им не мешает?)

В __T__-клетках:
* апрегуляция: ISG

"Analysis of predicted upstream regulators indicated a strong IFN-driven response that was starkly absent from half of the profiled COVID-19 samples in both NK cells, CD4+ and CD8+ T cells" - _снова рандом_

"Although some ISGs were upregulated by most donors in a given cell type generally ISG upregulation was not uniform within cell types or between subjects".
"These results collectively indicate heterogeneous peripheral immune activation in COVID-19." - _т.е. как пойдёт?_

### Фенотипы "развивающихся нейтрофилов" и клеток плазмы
Судя по UMAP, они как-то связаны...
"developing neutrophils appeared to project linearly from plasmablasts, suggestive of a continuum of cellular phenotype between the two cell types"

Чтобы определить, есть ли переходны между этими типами клеток, ребята выполнили "cellular trajectory analysis by RNA velocity" и обнаружили, что между ними таки есть "мост дифференциации" у всех пациентов с ОРДС.
У клеток на этом мосту снижается экспрессия генов маркеров плазмобластов (CD27, CD38, TNFRSF17) и повышается экспрессия первичных, вторичных и третичных белков гранул нейтрофилов.

Дифференциация из лимфоцитов в гранулоциты уже встречалась (из В-клеток в магрофаки или гранулоциты), и контролировался этот процесс C/Enhancer Binding Protein (C/EBP).
Принадлижащие к этому семейству (_классу?_) гены (CEBPE, CEBPD) селективно экспрессируют по всему мосту дифференциации ("along the differentiation bridge")

"Overall, we used single-cell transcriptomics to characterize peripheral immune responses in severe COVID-19. We observed marked changes in the immune cell composition and phenotype in SARS-CoV-2 infection and immunological features of severe COVID-19 in patients with ARDS."

---
---
* 3 из пациентов принимали Азитромицин, который мог повлиять на имунный ответ
* peripheral blood - ? ? ?
