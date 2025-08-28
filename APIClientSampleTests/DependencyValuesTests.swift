//
//  DependencyValuesTests.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/08/24
//  

@testable import APIClientSample
import Foundation
import Testing

// MARK: - test case

struct DependencyValuesTests {

    @Test("liveValueフォールバックを確認")
    func defaultLiveValues_areUsed_whenNotOverridden() {
        
        #expect(IntReader().intGen == 0)
        #expect(UUIDReader().uuidGen == UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
    }

    @Test("withDependency(同期)のスコープと復元を確認")
    func withDependency_sync_scopesAndRestores() {
        
        #expect(IntReader().intGen == 0)
        let result: Int = DependencyValues.withDependency { $0.intGen = 123 } operation: { IntReader().intGen }
        #expect(result == 123)
        #expect(IntReader().intGen == 0)
    }

    @Test("withDependency(非同期)のスコープと復元・子Task継承/Detached非継承を確認")
    func withDependency_async_scopesAndInheritance() async {
        
        #expect(IntReader().intGen == 0)
        await DependencyValues.withDependency { $0.intGen = 999 } operation: {
            
            #expect(IntReader().intGen == 999)
            let inherited = await Task { IntReader().intGen }.value
            #expect(inherited == 999)
            let detached = await Task.detached { IntReader().intGen }.value
            #expect(detached == 0)
        }
        #expect(IntReader().intGen == 0)
    }

    @Test("async letでのTask-Local継承を確認")
    func asyncLet_inheritsTaskLocal() async {
        
        @Sendable func readAsync() async -> Int { IntReader().intGen }
        await DependencyValues.withDependency { $0.intGen = 314 } operation: {
            
            async let a = readAsync()
            async let b = readAsync()
            let (va, vb) = await (a, b)
            #expect(va == 314)
            #expect(vb == 314)
        }
        #expect(IntReader().intGen == 0)
    }

    @Test("ネストした上書きの優先順位と巻き戻りを確認")
    func withDependency_nested_overrideAndUnwind() {
        
        let v1 = DependencyValues.withDependency { $0.intGen = 1 } operation: { IntReader().intGen }
        #expect(v1 == 1)
        
        let v2 = DependencyValues.withDependency { $0.intGen = 1 } operation: {
            
            DependencyValues.withDependency { $0.intGen = 2 } operation: { IntReader().intGen }
        }
        #expect(v2 == 2)
        
        let back = DependencyValues.withDependency { $0.intGen = 1 } operation: { IntReader().intGen }
        #expect(back == 1)
    }

    @Test("複数キーの同時上書きを確認")
    func overrideMultipleKeys_and_DependencyWrapperResolvesKeyPath() {
        
        let u = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        let (intReader, uuidReader) = DependencyValues.withDependency {
            
            $0.intGen = 7
            $0.uuidGen = u
        } operation: {
            
            let intReader = IntReader()
            let uuidReader = UUIDReader()
            
            return (intReader, uuidReader)
        }
        
        #expect(intReader.intGen == 0)
        #expect(uuidReader.uuidGen == UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
    }

    @Test("未設定キーは常にliveValueにフォールバックすることを確認（他キーが上書きされていても）")
    func fallback_toLiveValue_whenOtherKeysOverridden() {
        
        DependencyValues.withDependency { $0.intGen = 42 } operation: {
            
            #expect(IntReader().intGen == 42)
            #expect(UUIDReader().uuidGen == UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
        }
        
        #expect(IntReader().intGen == 0)
        #expect(UUIDReader().uuidGen == UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
    }

    @Test("大量の兄弟タスクでの隔離（スレッド安全性）を確認")
    func siblingTasks_isolation_underLoad() async {
        
        let iterations = 300
        let ok = await withTaskGroup(of: Bool.self) { group in
            
            for i in 0..<iterations {
                
                group.addTask {
                    
                    await DependencyValues.withDependency { $0.intGen = i } operation: {
                        
                        let here = IntReader().intGen
                        let inherited = await Task { IntReader().intGen }.value
                        let detached = await Task.detached { IntReader().intGen }.value
                        return here == i && inherited == i && detached == 0
                    }
                }
            }
            var all = true
            for await b in group { all = all && b }
            return all
        }
        #expect(ok)
        #expect(IntReader().intGen == 0)
    }

    @Test("ランダムな待機を混ぜた並行実行でも相互干渉しないことを確認")
    func isolation_withRandomSleeps_underLoad() async {
        
        let iterations = 200
        let ok = await withTaskGroup(of: Bool.self) { group in
            
            for i in 0..<iterations {
                
                group.addTask {
                    
                    await DependencyValues.withDependency { $0.intGen = i } operation: {
                        
                        let nanos = UInt64(Int.random(in: 0...200_000))
                        try? await Task.sleep(nanoseconds: nanos)
                        let here = IntReader().intGen
                        try? await Task.sleep(nanoseconds: nanos / 2 + 1)
                        let again = IntReader().intGen
                        return here == i && again == i
                    }
                }
            }
            var all = true
            for await b in group { all = all && b }
            return all
        }
        #expect(ok)
        #expect(IntReader().intGen == 0)
    }

    @Test("DispatchQueueへはTask-Localが伝播しないことを確認")
    func dispatchQueue_doesNotInheritTaskLocal() async {
        
        await DependencyValues.withDependency { $0.intGen = 555 } operation: {
            
            let fromGCD: Int = await withCheckedContinuation { cont in
                DispatchQueue.global().async {
                    cont.resume(returning: IntReader().intGen)
                }
            }
            #expect(fromGCD == 0)
            #expect(IntReader().intGen == 555)
        }
        #expect(IntReader().intGen == 0)
    }

    @Test("深いネスト・再入でも巻き戻りが正しく行われることを確認")
    func deepNesting_overrideAndUnwind() async {
        
        await DependencyValues.withDependency { $0.intGen = 1 } operation: {
            
            #expect(IntReader().intGen == 1)
            await DependencyValues.withDependency { $0.intGen = 2 } operation: {
                
                #expect(IntReader().intGen == 2)
                await DependencyValues.withDependency { $0.intGen = 3 } operation: {
                    
                    #expect(IntReader().intGen == 3)
                    await Task.yield()
                    #expect(IntReader().intGen == 3)
                }
                #expect(IntReader().intGen == 2)
            }
            #expect(IntReader().intGen == 1)
        }
        #expect(IntReader().intGen == 0)
    }
}

// MARK: - test data

private enum IntGeneratorKey: DependencyKey {
    
    typealias Value = Int
    static let liveValue: Value = 0
}

private enum UUIDGeneratorKey: DependencyKey {
    
    typealias Value = UUID
    static let liveValue: Value = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}

extension DependencyValues {
    
    var intGen: Int {
        
        get { self[IntGeneratorKey.self] }
        set { self[IntGeneratorKey.self] = newValue }
    }
    var uuidGen: UUID {
        
        get { self[UUIDGeneratorKey.self] }
        set { self[UUIDGeneratorKey.self] = newValue }
    }
}

private struct IntReader {
    
    @Dependency(\.intGen) var intGen
}
private struct UUIDReader {
    
    @Dependency(\.uuidGen) var uuidGen
}
