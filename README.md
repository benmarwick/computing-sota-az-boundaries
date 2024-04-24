
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Computing Activation Zone Boundaries for [SOTA](https://www.sota.org.uk/) Summits in W7W

<!-- badges: start -->

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/benmarwick/computing-sota-az-boundaries/master?urlpath=rstudio)

<!-- badges: end -->

### Background

The goal of this repository is to generate polygons that indicate the
[activation zones](https://www.sota.org.uk/Blog/2017/07/08/In-The-Zone)
for [SOTA](https://www.sota.org.uk/) summits in the W7W-KG area. Here is
how the [SOTA FAQ](https://www.sota.org.uk/Joining-In/FAQs) defines the
activation zone:

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
GeoJSON files that can be integrated into the sotl.as map. This is
inspired by the work done for HB/HB0 and OE, where operators can view
the activation zone polygon directly in the sotl.as map Currently this
project only does summits in the W7W area. Here I use the R programming
language to access the Washington State’s Department of Natural
Resources public LIDAR portal: <https://lidarportal.dnr.wa.gov/> For
each SOTA summit I download a small raster file of elevation data for
each summit, and compute the activation zone polygon and save it to a
GeoJSON file. Please inspect the R Markdown files in this repository for
more details of the calculations.

Currently this repository has GeoJSON files for activation zones in the
following regions in the W7W association:

- KG (King County): currently visible on
  [sotl.as](https://sotl.as/summits/W7W/KG)
- CW (Central Washington): not yet on [sotl.as](https://sotl.as/W7W/CW)
- LC (Lower Columbia): not yet on [sotl.as](https://sotl.as/W7W/LC)
- RS (Rainer Salish): not yet on [sotl.as](https://sotl.as/W7W/RS)
- SK (Skagit): not yet on [sotl.as](https://sotl.as/W7W/SK)
- CH (Chelan): not yet on [sotl.as](https://sotl.as/W7W/CH)

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
