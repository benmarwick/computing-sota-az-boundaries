
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Computing Activation Zone Boundaries for [SOTA](https://www.sota.org.uk/) Summits in W7W

<!-- badges: start -->

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/benmarwick/computing-sota-az-boundaries/master?urlpath=rstudio)

<!-- badges: end -->

### Background

The goal of this repository is to generate polygons that indicate the
[activation zones](https://www.sota.org.uk/Blog/2017/07/08/In-The-Zone)
for [SOTA](https://www.sota.org.uk/) summits in the W7W area (Washington
State, USA). Here is how the [SOTA
FAQ](https://www.sota.org.uk/Joining-In/FAQs) defines the activation
zone:

> Q. What is the Activation Zone?

> A. Often it is inconvenient to operate from the actual highest point
> of a summit, there may be structures there, or on a frequently visited
> summit there may be too many people about. The SOTA rules permit the
> operating position to be away from the summit but not more than 25
> vertical metres below the summit. If you draw a contour line on a map
> 25 metres below the summit, the area within this contour is the
> Activation Zone. See this [MT blog
> posting](https://www.sota.org.uk/Blog/2017/07/08/In-The-Zone) for more
> information. If you operate from outside the AZ, the activation is not
> valid and will score no points.

### Prior work on computing SOTA activation zones

- the web app <https://activation.zone/> by [Ara
  N6ARA](https://n6ara.com/) which uses 30m elevation data with global
  coverage provided by the [elevation Python
  package](https://pypi.org/project/elevation/). This is fast and easy
  to use, but relatively low resolution.
- On [sotl.as](https://sotl.as/) activation zones are visible in the map
  view for HB/HB0 (calculated using
  [swissALTI3D](https://www.swisstopo.admin.ch/de/hoehenmodell-swissalti3d)
  data from swisstopo (spatial resolution 0.5 m, accuracy ± 0.3 – 3 m
  (1σ) depending on the region) and OE (calculated using BEV ALS DTM
  data (spatial resolution 1 m, accuracy generally ± 0.5 m, may vary in
  high altitude). The OE activation zones were computed by [Tobi
  OE7TOK](https://reflector.sota.org.uk/t/activation-zones-for-oe-on-sotlas/34629).
- [Caltopo](https://caltopo.com/) can also be used to compute activation
  zones using the DEM shading tool on a desktop computer or smartphone
  (see [Tim N7KOM’s](https://www.etsy.com/shop/N7KOMPortableRadio)
  [tutorial](https://www.youtube.com/watch?v=UixA1Fc4D1c) on how to do
  this). CalTopo’s elevation data is up to 1 meter resolution in many
  areas, which is based on LIDAR scans from the USGS’s 3DEP program.
  This is a high resolution freely available tool for on-the-fly
  computation of activation zone areas. However, it can be a bit fiddly
  to use when using on a small screen on a summit.

### This project

The goal of these project is generate activation zone polygons as
GeoJSON files that can be integrated into the [sotl.as
map](https://sotl.as/summits/W7W) for W7W. This is inspired by the work
done for HB/HB0 and OE, where operators can view the activation zone
polygon directly in the sotl.as map. Currently this project has computed
polygons for activation zones for 2257 summits in the W7W area. The
[official SOTA database](https://www.sotadata.org.uk/en/association/W7W)
has 2762 summits recorded for W7W, so 81.7% of all summits in W7W have
an activation zone. We’re unable to compute activation zones for summits
in areas that currently do not have lidar imagery.

Here I use the R programming language to access the [Washington State’s
Department of Natural Resources public LIDAR
portal](https://lidarportal.dnr.wa.gov/). In brief, my method was to
automatically download a small raster file of elevation data for each
summit, compute the activation zone polygon, and save it to a GeoJSON
file. Please inspect the R Markdown files in this repository for more
details of the calculations. I visually inspected each activation zone
polygon to ensure there were no errors, but if you find something that
looks odd, please let me know and I’ll take another look.

Currently this repository has GeoJSON files for activation zones in the
following regions in the W7W association:

<table>
<thead>
<tr>
<th style="text-align:left;">
Region
</th>
<th style="text-align:left;">
Code
</th>
<th style="text-align:right;">
Number of summits
</th>
<th style="text-align:right;">
Number of activation zones
</th>
<th style="text-align:right;">
Percentage of summits with activation zones
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
WA-Northern Olympics
</td>
<td style="text-align:left;">
NO
</td>
<td style="text-align:right;">
260
</td>
<td style="text-align:right;">
260
</td>
<td style="text-align:right;">
100.0
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Chelan
</td>
<td style="text-align:left;">
CH
</td>
<td style="text-align:right;">
244
</td>
<td style="text-align:right;">
244
</td>
<td style="text-align:right;">
100.0
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Lower Columbia
</td>
<td style="text-align:left;">
LC
</td>
<td style="text-align:right;">
169
</td>
<td style="text-align:right;">
169
</td>
<td style="text-align:right;">
100.0
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-King
</td>
<td style="text-align:left;">
KG
</td>
<td style="text-align:right;">
160
</td>
<td style="text-align:right;">
160
</td>
<td style="text-align:right;">
100.0
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Rainier-Salish
</td>
<td style="text-align:left;">
RS
</td>
<td style="text-align:right;">
91
</td>
<td style="text-align:right;">
91
</td>
<td style="text-align:right;">
100.0
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Southern Olympics
</td>
<td style="text-align:left;">
SO
</td>
<td style="text-align:right;">
122
</td>
<td style="text-align:right;">
121
</td>
<td style="text-align:right;">
99.2
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Stevens
</td>
<td style="text-align:left;">
ST
</td>
<td style="text-align:right;">
152
</td>
<td style="text-align:right;">
150
</td>
<td style="text-align:right;">
98.7
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Pacific-Lewis
</td>
<td style="text-align:left;">
PL
</td>
<td style="text-align:right;">
168
</td>
<td style="text-align:right;">
163
</td>
<td style="text-align:right;">
97.0
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Washington East
</td>
<td style="text-align:left;">
WE
</td>
<td style="text-align:right;">
55
</td>
<td style="text-align:right;">
53
</td>
<td style="text-align:right;">
96.4
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Pend Oreille
</td>
<td style="text-align:left;">
PO
</td>
<td style="text-align:right;">
82
</td>
<td style="text-align:right;">
78
</td>
<td style="text-align:right;">
95.1
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Middle Columbia
</td>
<td style="text-align:left;">
MC
</td>
<td style="text-align:right;">
95
</td>
<td style="text-align:right;">
89
</td>
<td style="text-align:right;">
93.7
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Central Washington
</td>
<td style="text-align:left;">
CW
</td>
<td style="text-align:right;">
108
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
92.6
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Snohomish
</td>
<td style="text-align:left;">
SN
</td>
<td style="text-align:right;">
184
</td>
<td style="text-align:right;">
136
</td>
<td style="text-align:right;">
73.9
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Skagit
</td>
<td style="text-align:left;">
SK
</td>
<td style="text-align:right;">
181
</td>
<td style="text-align:right;">
131
</td>
<td style="text-align:right;">
72.4
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Ferry
</td>
<td style="text-align:left;">
FR
</td>
<td style="text-align:right;">
137
</td>
<td style="text-align:right;">
72
</td>
<td style="text-align:right;">
52.6
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Whatcom
</td>
<td style="text-align:left;">
WH
</td>
<td style="text-align:right;">
207
</td>
<td style="text-align:right;">
102
</td>
<td style="text-align:right;">
49.3
</td>
</tr>
<tr>
<td style="text-align:left;">
WA-Okanogan
</td>
<td style="text-align:left;">
OK
</td>
<td style="text-align:right;">
347
</td>
<td style="text-align:right;">
140
</td>
<td style="text-align:right;">
40.3
</td>
</tr>
</tbody>
</table>

### Licenses

**Text and figures :**
[CC-BY-4.0](http://creativecommons.org/licenses/by/4.0/)

**Code :** see [LICENSE.md](LICENSE.md)

**Data :** [CC-0](http://creativecommons.org/publicdomain/zero/1.0/)

### Contributions

We welcome contributions from everyone. Before you get started, please
see our [contributor guidelines](CONTRIBUTING.md). Please note that this
project is released with a [Contributor Code of Conduct](CONDUCT.md). By
participating in this project you agree to abide by its terms.
