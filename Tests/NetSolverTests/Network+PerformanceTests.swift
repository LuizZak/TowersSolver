import XCTest
@testable import NetSolver

class Network_PerformanceTests: XCTestCase {
    func testSplitNetwork_unsolvedGrid_performance() {
        let grid = TestGridBuilder(columns: 30, rows: 30)
            .fromGameID("""
                97695a6389249552211241c8cc551418db85b747dbb411a5555476c39c8a4c\
                8585c377d141edc67da456da3515178e495451beded21263a377c899bc895d\
                4a7bb4d86ae7e972631d6c6b71ca389772dca25d9919311c67342b994bb18b\
                71e2e12d65858e967b4b1ac812c7a142e1b28e73263eab64354b72a87c9a38\
                88d5a6e6297eab525b7999a174a5e556395decab9928c2774e567a79c19de2\
                31828d5a3e43dcb35d9112774581cca8d767ea115a856556a24287e3adbdd4\
                9b2ce775bbaeb821766d5b7a7155525a487729ae92bed2c41563c8656dbbd4\
                ced57e48a3bcaad83ed24e6147693b5ea41d73c67bb38156c4689e425c5b38\
                a33b1e121458cca2b5bbdbb7cc7ad4b7bb548117d3ec3385d73b1e85362271\
                ceddbb8b1d649b65c24217274e99bb925c6e45cb62a251593b3966abad34a3\
                76458d7cbcb9815b59ced34a52c25ccd8d3cb8a45679275d5da35d68cbb4ab\
                c118d23369151a8938588e61584631533275718d81dbd2a11cdbbb9a679277\
                9bc8e1485c2c3c6ee9c6a973cb8ced4179be9b5d9a195b11e34c65429b47d4\
                345a132ebe924d8657241e782eca9ba31143bcc57e5a682bdbc9d827ab878e\
                dcc32292c328bad946181a56424d8824
                """)
            .build()
        let sut = Network.fromGrid(grid)
        
        doMeasure {
            _ = sut.splitNetwork(onGrid: grid)
        }
    }
    
    func testSplitNetwork_solvedGrid_performance() {
        let grid = TestGridBuilder(columns: 30, rows: 30)
            .fromGameID("""
                88888155c815c15c1d55555ddd54883eab6888a3d43d56975548822288aa1e\
                a3d63e357c8a88b48896a948b6aa17e1e817555eab63e17ebd6a97697615e1\
                e35555d6b7417dd7635ea897549cb43dc9c1e9e8881e2881c2b77554aa3c8a\
                2235e2ab6a9e8aa8a8b5495423c377d494b4b7ca2ab76aab754a881d75c17d\
                e8a1e16a8b748aab554aaa9688a15e3ea83dd77748a3eb494ab629777dd68a\
                b7c2b54943e977561ea88215c2a9ea28b4a817d56b5c941e3e3d483c22b61e\
                a8a3dde94bc2a1d7de8a975e1cb48b6a3ca22b5e3d75682a3761c3577d77c3\
                d6a1d743435497c281c8b41dcb4175e9757495dd497428b4b77dca368888be\
                889574235e9d5e35615ea3556ab6ab7775d5c942a2829dd55e35dd5775e355\
                5c3c375ca1e822a95e1de21ddd7dd49e97d5c2b4aa9d6a174abc16ab4ab4aa\
                b4b4bd74b62a97c95e2bd4a3423ca2bc216b5d7c9eb4221e9e2175dd42a1ea\
                81de83c22a348896ab5c882bd4a9eab5ebe8288a9577e96bcab7cab42a2234\
                a2be1ebe3481e2962b7caab41e89dd682bd6abdc3568bc9e1eaa3d4a3e2bcb\
                4ab42a2bc88bea2a1e2b4b42969e37cabc9e822b7ea217c3ca1695e82bd4a2\
                2a223556163415742341742356343416
                """)
            .build()
        let sut = Network.fromGrid(grid)
        
        doMeasure {
            _ = sut.splitNetwork(onGrid: grid)
        }
    }
    
    func testFromLockedTiles_performance() {
        let grid = TestGridBuilder(columns: 30, rows: 30)
            .fromGameID("""
                97695a6389249552211241c8cc551418db85b747dbb411a5555476c39c8a4c\
                8585c377d141edc67da456da3515178e495451beded21263a377c899bc895d\
                4a7bb4d86ae7e972631d6c6b71ca389772dca25d9919311c67342b994bb18b\
                71e2e12d65858e967b4b1ac812c7a142e1b28e73263eab64354b72a87c9a38\
                88d5a6e6297eab525b7999a174a5e556395decab9928c2774e567a79c19de2\
                31828d5a3e43dcb35d9112774581cca8d767ea115a856556a24287e3adbdd4\
                9b2ce775bbaeb821766d5b7a7155525a487729ae92bed2c41563c8656dbbd4\
                ced57e48a3bcaad83ed24e6147693b5ea41d73c67bb38156c4689e425c5b38\
                a33b1e121458cca2b5bbdbb7cc7ad4b7bb548117d3ec3385d73b1e85362271\
                ceddbb8b1d649b65c24217274e99bb925c6e45cb62a251593b3966abad34a3\
                76458d7cbcb9815b59ced34a52c25ccd8d3cb8a45679275d5da35d68cbb4ab\
                c118d23369151a8938588e61584631533275718d81dbd2a11cdbbb9a679277\
                9bc8e1485c2c3c6ee9c6a973cb8ced4179be9b5d9a195b11e34c65429b47d4\
                345a132ebe924d8657241e782eca9ba31143bcc57e5a682bdbc9d827ab878e\
                dcc32292c328bad946181a56424d8824
                """)
            .setAllTilesLocked(true)
            .build()
        
        doMeasure {
            _ = Network.fromLockedTiles(onGrid: grid)
        }
    }
    
    func testHasLoops_unsolvedGrid_performance() {
        let grid = TestGridBuilder(columns: 30, rows: 30)
            .fromGameID("""
                2821145ac84ac2538ba55aaee7512467ae3424a37437a337a524418211a517\
                a673c79adc8521b8816c5c42e3aa1ed2d247aa5b5bc3d1e7dd35cd39d64ab8\
                79a5aa73e741ebebcc57a13b5299b29b99c1e6718887888431bedaa4aa692a\
                84cab8a79acd2a5252ba2c5186367bd2c4d1bbc52aee65a7b515481eea92dd\
                d45274654e784aabaa15aa662151a7cda4cbbe7741a37b1315b68cede7798a\
                d794ea8683b3dba34758184a6856b548b1a887eacdac9217373d8493127c4e\
                58acdbdc4b9452eede85c75b23b84b3a36a81e5ece75c24acb326cabedde33\
                ec58de4943516bc448c4b12b9b18b57ce572357e86d242d8d7eb656c1121db\
                429ab11cab97a735c1575c5a3ad95eebe5753941a2813bdaadcae7a7e5b9a5\
                a3cc3756a4d842a9a71dd21dbbebe83e3dbac4e8aa3b3a1715e316a72ab2aa\
                d878dbe1e62a3b66ae4eb2a612cc52762897abd3cdd442279b12e5b718a2ea\
                12db2cc22a9442c95e5c1427b153e5da7dd4482acadbb9973abd6ab4852432\
                a17d4eed621871968eec55d81719eec14dbcabd63a94e69e2b553e2a6d876b\
                1ad14a4e3187da1a2e2d4d82c93e976a796e24477da18ec69a8ccab21e7451\
                4a423a5c4c328ab84328b2435631c849
                """)
            .build()
        let sut = Network.fromGrid(grid)
        
        doMeasure {
            _ = sut.hasLoops(onGrid: grid)
        }
    }
    
    func testHasLoops_solvedGrid_performance() {
        let grid = TestGridBuilder(columns: 30, rows: 30)
            .fromGameID("""
                88888155c815c15c1d55555ddd54883eab6888a3d43d56975548822288aa1e\
                a3d63e357c8a88b48896a948b6aa17e1e817555eab63e17ebd6a97697615e1\
                e35555d6b7417dd7635ea897549cb43dc9c1e9e8881e2881c2b77554aa3c8a\
                2235e2ab6a9e8aa8a8b5495423c377d494b4b7ca2ab76aab754a881d75c17d\
                e8a1e16a8b748aab554aaa9688a15e3ea83dd77748a3eb494ab629777dd68a\
                b7c2b54943e977561ea88215c2a9ea28b4a817d56b5c941e3e3d483c22b61e\
                a8a3dde94bc2a1d7de8a975e1cb48b6a3ca22b5e3d75682a3761c3577d77c3\
                d6a1d743435497c281c8b41dcb4175e9757495dd497428b4b77dca368888be\
                889574235e9d5e35615ea3556ab6ab7775d5c942a2829dd55e35dd5775e355\
                5c3c375ca1e822a95e1de21ddd7dd49e97d5c2b4aa9d6a174abc16ab4ab4aa\
                b4b4bd74b62a97c95e2bd4a3423ca2bc216b5d7c9eb4221e9e2175dd42a1ea\
                81de83c22a348896ab5c882bd4a9eab5ebe8288a9577e96bcab7cab42a2234\
                a2be1ebe3481e2962b7caab41e89dd682bd6abdc3568bc9e1eaa3d4a3e2bcb\
                4ab42a2bc88bea2a1e2b4b42969e37cabc9e822b7ea217c3ca1695e82bd4a2\
                2a223556163415742341742356343416
                """)
            .build()
        let sut = Network.fromGrid(grid)
        
        doMeasure {
            _ = sut.hasLoops(onGrid: grid)
        }
    }
    
    func testHasLoops_largeLoop_performance() {
        let grid = TestGridBuilder(columns: 30, rows: 30)
            .fromGameID("""
                c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
                363636363636363636363636363636
                """)
            .setAllTilesLocked(true)
            .build()
        let sut = Network.fromGrid(grid)
        
        doMeasure {
            _ = sut.hasLoops(onGrid: grid)
        }
    }
}
