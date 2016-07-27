Kino/Vision
===========

*Vision* is a utility image effect for Unity, which visualizes frame
information.

![Screen][Image1]

Currently *Vision* provides following three different modes.

#### Depth Mode

![Screen][Image2] ![Screen][Image3]

This visualizes depth information of the frame with color gradients. The color
changes from white (near) to red (medium) to black (far).

It retrieves depth information from the [CameraDepth texture][DepthTexture] by
default, or from the [CameraDepthNormals texture][DepthTexture] when the *Use
Depth Normals* toggle is turned on.

The *Repeat* property changes the repetition of the gradient. This is useful to
inspect depth difference within a narrow range.

**Normals Mode**

![Screen][Image4]

This visualizes normals of the frame with color gradients. It tries to retrieve
normals from G-buffer if it's available. When G-buffer is not available or the
*Use Depth Normals* toggle is enabled, it switches to use the
[CameraDepthNormals][DepthTexture] texture.

It shows invalid normals (length != 1.0) with red pixels when the *Check
Validity* toggle is enabled.

**Motion Vectors Mode**

![Screen][Image5]

This visualizes motion vectors of the frame with color gradients and arrows.

System Requirements
-------------------

Unity 5.4 or later versions.

License
-------

Copyright (C) 2016 Keijiro Takahashi

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[Image1]: http://66.media.tumblr.com/f920fa1eeca013ff54abb98272530ad5/tumblr_o7xmw6zizD1qio469o1_500.png
[Image2]: http://66.media.tumblr.com/3c880d46c2d5b83516814ddba6e57a4f/tumblr_oaykyuC0B41qio469o3_400.png
[Image3]: http://67.media.tumblr.com/32c6f72ea0b75863ba15b0d17f5414ae/tumblr_oaykyuC0B41qio469o2_400.png
[Image4]: http://67.media.tumblr.com/77669d79a2097ca4712460c593e9085f/tumblr_oaykyuC0B41qio469o1_400.png
[Image5]: http://67.media.tumblr.com/91fb643321541dd195dcce5487e514e4/tumblr_o7xmw6zizD1qio469o2_400.png
[Kino]: https://github.com/search?q=kino+user%3Akeijiro&type=Repositories
[DepthTexture]: https://docs.unity3d.com/Manual/SL-CameraDepthTexture.html
