---
layout: page_map
title: Classification Quality
---


Map of the Quality of Classification for the University Forest Caldern
----------------------------------------------------------

This is the map for the quality of the classification for the University Forest Caldern. Be aware that the file size approximatley **100 MB**.

Each segment is classified to a specific species by counting the pixels
within the segment. The majority class is used to label the segment.
[Quality](https://github.com/goergen95/mof_caldern/blob/master/src/011_structure_values.R#L62)
thus is measured here by the percentage of the majority pixels within a
tree segment. Trees where two or more classes have the same number of
pixels within a segment were excluded because no clear species label
could be attributed to these segments.

<div class="map_container">
    <iframe class="map_iframe" src="../assets/maps/mapobjects/quality.html" width="600" height="450" frameborder="0"
    ></iframe>
</div>