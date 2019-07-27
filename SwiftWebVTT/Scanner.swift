import Foundation

internal class CustomScanner {
    private let scanner: Scanner
    private let length: Int
    init(string: String) {
        scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = nil
        length = (string as NSString).length
    }
    
    var scanLocation: Int {
        get { return scanner.scanLocation }
        set { scanner.scanLocation = newValue }
    }
    var isAtEnd: Bool { return scanLocation == length }
    
    @discardableResult
    func scanUpToCharacters(from set: CharacterSet, thenSkip skipCount: Int = 0) -> String? {
        let string = scanner.scanUpToCharacters(from: set)
        if string != nil, skipCount > 0 { skip(skipCount) }
        return string
    }
    
    @discardableResult
    func scanCharacters(from set: CharacterSet, thenSkip skipCount: Int = 0) -> String? {
        let string = scanner.scanCharacters(from: set)
        if string != nil, skipCount > 0 { skip(skipCount) }
        return string
    }
    
    func scanInt(hexadecimal: Bool = false) -> Int? {
        switch hexadecimal {
        case true:
            let allowedSet = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
            guard let text = scanner.scanCharacters(from: allowedSet) else { break }
            let scanner = Scanner(string: "0x\(text)")
            var value: UInt64 = 0
            guard scanner.scanHexInt64(&value) else { break }
            return Int(value)
        case false:
            guard let text = scanner.scanCharacters(from: .decimalDigits) else { break }
            return Int(text)
        }
        return nil
    }
    
    func scanCharacter() -> Character? {
        return peekCharacter(thenSkip: true)
    }
    
    func scan(_ count: Int) -> String? {
        return peek(count, thenSkip: true)
    }
    
    func peek(_ count: Int, thenSkip: Bool = false) -> String? {
        guard !isAtEnd else { return nil }
        let count = min(count, length - scanLocation)
        let string = scanner.string as NSString
        let range = NSRange(location: scanLocation, length: count)
        if thenSkip { scanLocation += count }
        return string.substring(with: range) as String
    }
    
    func peekCharacter(thenSkip: Bool = false) -> Character? {
        guard !isAtEnd else { return nil }
        let string = scanner.string as NSString
        let c = string.character(at: scanLocation)
        if thenSkip { scanLocation += 1 }
        if let scalar = Unicode.Scalar(c) { return Character(scalar) }
        return nil
    }
    
    func skip(_ count: Int) {
        scanLocation += count
    }
}

private extension Scanner {
    func scanCharacters(from set: CharacterSet) -> String? {
        var string: NSString? = nil
        if scanCharacters(from: set, into: &string) { return string as String? }
        return nil
    }
    
    func scanUpToCharacters(from set: CharacterSet) -> String? {
        var string: NSString? = nil
        if scanUpToCharacters(from: set, into: &string) { return string as String? }
        return nil
    }
}
