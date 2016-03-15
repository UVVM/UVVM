*"Open Source VHDL Verification Methodology" (OSVVM) Repository*

------
[**Open Source VHDL Verification Methodology (OSVVM)**][osvvm] is an intelligent testbench methodology that allows mixing of “Intelligent Coverage” (coverage driven randomization) with directed, algorithmic, file based, and constrained random test approaches. The methodology can be adopted in part or in whole as needed. With OSVVM you can add advanced verification methodologies to your current testbench without having to learn a new language or throw out your existing testbench or testbench models.

**Source:**     [http://www.osvvm.org/][osvvm]  
**OSVVM Blog:** [http://www.synthworks.com/blog/osvvm/][osvvm-blog]  
**License:**	[Artistic License 2.0][PAL2.0]  
**Copyright:**	Copyright © 2006-2016 by [SynthWorks Design Inc.](http://www.synthworks.com/)

## Release History
 - Jan-2016 - **2016.01**  Fix limit of 32 AlertLogIDs, Updates for GHDL (Purity and L.all(L'left)), 
 - Jul-2015 - **2015.06**  Addition of MemoryPkg
 - Mar-2015 - **2015.03**  Bug fixes to AlertLogPkg (primarily ClearAlerts, but also matching names)
 - Jan-2015   **2015.01**  Not here. Addition of AlertLogPkg, TranscriptPkg,OsvvmContext, and OsvvmGlobalPkg.  
 - Dec-2014 - **2014.07a** Fixed memory leak in CoveragePkg.Deallocate.  Replaced initialized pointers with initialization functions
 - Jul-2014 - **2014.07**  Not here. Added names to coverage bins.  Added option during WriteBin so that a bin prints PASSED if its count is greater than the coverage goal, otherwise FAILED.  
 - Jan-2014 - **2014.01**  RandomPkg: RandTime, RandIntV, RandRealV, RandTimeV.  CoveragePkg:  Support merging of coverage bins.  
 - May-2013 - **2013.05**  RandomPkg:  Big Vector Randomization.  
 
 For more revision information, see [osvvm_release_notes.pdf](doc/osvvm_release_notes.pdf)


------

*Starting with 2016.01, this repository was handed off to Jim Lewis (OSVVM Developer) and became the GIT site for OSVVM*  
*Releases prior to 2016.01 were uploaded by Patrick Lehmann*

 [osvvm]:      http://www.osvvm.org/
 [osvvm-blog]: http://www.synthworks.com/blog/osvvm/
 [aldec]:      http://www.aldec.com/
 [PAL2.0]:	   http://www.perlfoundation.org/artistic_license_2_0





