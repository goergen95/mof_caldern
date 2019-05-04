---
layout: default
---

<h2> Welcome!</h2>

<h3>First notes</h3>

If you are seeing this, it means you have scanned one of our QR codes or followed one of our links elsewhere. We are happy that you are interested in the results of our tree species classification as well as in our analysis of biological diversity of the University Forest Caldern! This website describes the main results of our one semester seminar to map forest structures based on RGB aerial photographs as well as LiDAR data. The reasons to create this webpage are twofold. Firstly, we thought that an interactive presentation of our findings can be a good way to make people understand and engage with it and enable them to actually create information from data and use it for beneficial purposes. Secondly, we wanted to learn how to set up and maintain a project page on GitHub, how to communicate statistical findings and creating interactive mapping features. Since this webpage is hosted on GitHub, we were quite limited when it came to file size. That is why the interactive maps of our analysis cannot be hosted here. However, you can find links which will lead you to the proper files on servers maintained by the Environmental Informatics Department of the University of Marburg. Be aware that these files are large (usually over 100 MB), so ensure you have a Wi-Fi connection when accessing them.



Last, but not least, you are invited to leave your comments and ideas you may have interacting with our code and data. We hope you enjoy!

<!-- Section -->

<section>
    <header class="major">
        <h2>Content</h2>
    </header>
    <div class="posts">
        <article>
            <a href="{{ 'pages/segmentation.html' | absolute_url }}" class="image"><img src="assets/images/seg_area_2.gif" alt="" width="256" height="301" /></a>
            <h3>Tree Segmentation</h3>
            <p>Based on LIDAR point cloud data and the ForestTools segmentation algorithm we segmented individual trees for the University Forest Caldern.</p>
            <ul class="actions">
                <li><a href="{{ 'pages/segmentation.html' | absolute_url }}" class="button">More</a></li>
            </ul>
        </article>
        <article>
	<a href="{{ 'pages/rf.html' | absolute_url }}" class="image"><img src="assets/images/cf_alluvial.png" alt="" width="256" height="301" /></a>
	<h3>Species Classification</h3>
	<p>By using a Random Forest Classifier and combining the segmented tree layer with low-cost RGB images we were able to classifi the species of individual trees.</p>
	<ul class="actions">
		<li><a href="{{ 'pages/rf.html' | absolute_url }}" class="button">More</a></li>
	</ul>
</article>
        <article>
	<a href="{{ 'pages/stat.html' | absolute_url }}" class="image"><img src="assets/images/species-min.png" alt="" width="256" height="301" /></a>
	<h3>Statistics</h3>
	<p>After the tree species classification we retrieved some information about the species distribution within the forest and the structural attributes associated with the species.</p>
	<ul class="actions">
		<li><a href="{{ 'pages/stat.html' | absolute_url }}" class="button">More</a></li>
	</ul>
</article>
        <article>
    <a href="{{ 'pages/classification.html' | absolute_url }}" class="image"><img src="assets/images/species.png" alt="" width="256" height="256" /></a>
    <h3>Classification Map</h3>
    <p>Here you can interact with the results of the species classification.</p>
    <ul class="actions">
        <li><a href="{{ 'pages/classification.html' | absolute_url }}" class="button">More</a></li>
    </ul>
</article>
        <article>
	<a href="{{ 'pages/quality.html' | absolute_url }}" class="image"><img src="assets/images/quality.PNG" alt="" width="256" height="256" /></a>
	<h3>Quality of Classification</h3>
	<p>Here you can interact with our assessment of classification quality.</p>
	<ul class="actions">
		<li><a href="{{ 'pages/quality.html' | absolute_url }}" class="button">More</a></li>
	</ul>
</article>
        <article>
	<a href="{{ 'pages/biodiversity.html' | absolute_url }}" class="image"><img src="assets/images/biodiv_acre.PNG" alt="" width="256" height="256" /></a>
	<h3>Biodiversity at 1 acre</h3>
	<p>Here you can interact with the results of biodiversity assessment in a one acre envrionment for each tree,</p>
	<ul class="actions">
		<li><a href="{{ 'pages/biodiversity.html' | absolute_url }}" class="button">More</a></li>
	</ul>
</article>
        <article>
	<a href="{{ 'pages/biodiversity30.html' | absolute_url }}" class="image"><img src="assets/images/biodiv_30.PNG" alt="" width="256" height="256" /></a>
	<h3>Biodiversity at 30 meter</h3>
	<p>Here you can interact with the results of biodiversity assessment in a 30 meter envrionment for each tree,</p>
	<ul class="actions">
		<li><a href="{{ 'pages/biodiversity30.html' | absolute_url }}" class="button">More</a></li>
	</ul>
</article>
        <article>
	<a href="{{ 'pages/biodiversity10.html' | absolute_url }}" class="image"><img src="assets/images/biodiv.PNG" alt="" width="256" height="256" /></a>
	<h3>Biodiversity at 10 meter</h3>
	<p>Here you can interact with the results of biodiversity assessment in a 10 meter envrionment for each tree,</p>
	<ul class="actions">
		<li><a href="{{ 'pages/biodiversity10.html' | absolute_url }}" class="button">More</a></li>
	</ul>
</article>
        <article>
	<a href="{{ 'pages/density.html' | absolute_url }}" class="image"><img src="assets/images/vertical_density.png" alt="" width="256" height="256" /></a>
	<h3>Vertical Density</h3>
	<p>Here you can interact with the results of the vertical density of the vegetation cover.</p>
	<ul class="actions">
		<li><a href="{{ 'pages/density.html' | absolute_url }}" class="button">More</a></li>
	</ul>
</article>
        <article>
    <a href="{{ 'pages/drcN.html' | absolute_url }}" class="image"><img src="assets/images/direct_neigh.PNG" alt="" width="256" height="256" /></a>
	<h3>Direct Neighbours</h3>
	<p>Here you can interact with the results of the analysis of the number of direct neighbours for each individual tree.</p>
	<ul class="actions">
		<li><a href="{{ 'pages/drcN.html' | absolute_url }}" class="button">More</a></li>
	</ul>
</article>
    </div>
</section>




























