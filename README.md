KinoVision
==========

**Vision** is a utility image filter for Unity that visualizes frame
information.

![Screen](https://i.imgur.com/qqHGi3yl.png)

System Requirements
-------------------

Unity 2017.1.0 or later

Installation
------------

Download one of the unitypackage files from the [Releases] page and import it
to a project.

[Releases]: https://github.com/keijiro/KinoVision/releases

Visualization Modes
-------------------

There are three different modes in the filter.

#### Depth Mode

![Screen](https://i.imgur.com/6Cb1m2um.png)
![Screen](https://i.imgur.com/sBuhyQ6m.png)

In Depth Mode, Vision visualizes the depth information of the frame with a color
gradient from white (near) to red (medium) to black (far).

It retrieves depth information from the [CameraDepth texture][DepthTexture] by
default, or from the [CameraDepthNormals texture][DepthTexture] when "Use Depth
Normals" is turned on.

The "Repeat" value is used to determine the repetition of the gradient. This is
useful to inspect depth difference within narrow ranges.

[DepthTexture]: https://docs.unity3d.com/Manual/SL-CameraDepthTexture.html

#### Normals Mode

![Screen](https://i.imgur.com/UR2OLdnm.png)

In Normals Mode, Vision visualizes normals in the frame with a color gradient.
It retrieves normals from G-buffer if it's available. In case G-buffer is not
available or "Use Depth Normals" is turned on, it switches to use the 
[CameraDepthNormals][DepthTexture] texture instead.

It shows invalid normals (length != 1.0) with red pixels when "Check Validity"
is turned on.

#### Motion Vectors Mode

![Screen](https://i.imgur.com/i96Lts7m.png)

In Motion Vectors Mode, Vision visualizes motion vectors in the frame with a
color gradients and arrows.

License
-------

[MIT](LICENSE.txt)
