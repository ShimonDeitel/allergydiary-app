import XCTest
@testable import AllergyDiary

@MainActor
final class AllergyDiaryTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeEntryLimit)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        let added = store.add(FlareUpEntry(title: "Test entry"))
        XCTAssertTrue(added)
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCannotAddBeyondFreeLimitWhenNotPro() {
        store.isPro = false
        while store.entries.count < Store.freeEntryLimit {
            _ = store.add(FlareUpEntry(title: "Filler"))
        }
        let added = store.add(FlareUpEntry(title: "Overflow"))
        XCTAssertFalse(added)
    }

    func testProUserCanExceedFreeLimit() {
        store.isPro = true
        for _ in 0..<(Store.freeEntryLimit + 5) {
            _ = store.add(FlareUpEntry(title: "Pro filler"))
        }
        XCTAssertGreaterThan(store.entries.count, Store.freeEntryLimit)
    }

    func testDeleteEntryRemovesIt() {
        let entry = FlareUpEntry(title: "To delete")
        _ = store.add(entry)
        XCTAssertTrue(store.entries.contains(where: { $0.id == entry.id }))
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testDeleteAtOffsetsRemovesCorrectEntry() {
        store.entries = []
        let a = FlareUpEntry(title: "A")
        let b = FlareUpEntry(title: "B")
        store.entries = [a, b]
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.title, "B")
    }

    func testSettingsPersistAcrossReload() {
        store.settings.remindersEnabled = false
        store.saveSettings()
        let reloaded = Store()
        XCTAssertFalse(reloaded.settings.remindersEnabled)
    }
}
