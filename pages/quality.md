---
layout: page
title: Classification Quality
---


Map of the Quality of Classification for the University Forest Caldern
----------------------------------------------------------

This is a preview of the map for the quality of classification for the University Forest Caldern. Unfortunatley, due to
file size limitations on github, the fully interactive version of the
[map](http://seminar.environmentalinformatics-marburg.de/Seminar_RS/quality.html)
is hosted by servers of the Environmental Informatics Department of the
University of Marburg. Be aware that the file size is above 100 MB.

Each segment is classified to a specific species by counting the pixels
within the segment. The majority class is used to label the segment.
[Quality](https://github.com/goergen95/mof_caldern/blob/master/src/011_structure_values.R#L62)
thus is measured here by the percentage of the majority pixels within a
tree segment. Trees where two or more classes have the same number of
pixels within a segment were excluded because no clear species label
could be attributed to these segments.

<img src="quality_files/figure-markdown_strict/unnamed-chunk-1-1.png" class="image" alt="Map Preview"
	title="Map Preview"/>


