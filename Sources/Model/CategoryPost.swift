////
///  CategoryPost.swift
//

import SwiftyJSON
import Moya


@objc(CategoryPost)
final class CategoryPost: Model {
    static let Version = 1

    let id: String
    let categoryPartial: CategoryPartial?
    let submittedAt: Date?
    let featuredAt: Date?
    let unfeaturedAt: Date?
    let removedAt: Date?
    let status: Status
    var actions: [Action]

    var post: Post? { return getLinkObject("post") }
    var category: Category? { return getLinkObject("category") }
    var submittedBy: User? { return getLinkObject("submitted_by") }
    var featuredBy: User? { return getLinkObject("featured_by") }
    var unfeaturedBy: User? { return getLinkObject("unfeatured_by") }
    var removedBy: User? { return getLinkObject("removed_by") }

    enum Status: String {
        case featured
        case submitted
        case unspecified
    }

    struct Action {
        enum Name: String {
            case feature
            case unfeature
        }

        let name: Name
        let label: String
        let request: ElloRequest
        var endpoint: ElloAPI { return .customRequest(request, mimics: .categoryPostActions) }

        init(name: Name, label: String, request: ElloRequest) {
            self.name = name
            self.label = label
            self.request = request
        }

        init?(name nameStr: String, json: JSON) {
            guard
                let method = json["method"].string.map({ $0.uppercased() }).flatMap({ Moya.Method(rawValue: $0) }),
                let url = json["href"].url,
                let name = Name(rawValue: nameStr)
            else { return nil }

            let label = json["label"].stringValue
            let parameters = json["body"].object as? [String: Any]
            self.init(name: name, label: label, request: ElloRequest(url: url, method: method, parameters: parameters))
        }
    }

    init(id: String, categoryPartial: CategoryPartial?, status: Status, actions: [Action], submittedAt: Date?, featuredAt: Date?, unfeaturedAt: Date?, removedAt: Date?)
    {
        self.id = id
        self.categoryPartial = categoryPartial
        self.status = status
        self.actions = actions
        self.submittedAt = submittedAt
        self.featuredAt = featuredAt
        self.unfeaturedAt = unfeaturedAt
        self.removedAt = removedAt
        super.init(version: CategoryPost.Version)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        status = Status(rawValue: decoder.decodeKey("status")) ?? .unspecified
        let actions: [[String: Any]] = decoder.decodeKey("actions")
        let version: Int = decoder.decodeKey("version")
        self.actions = actions.compactMap { Action.decode($0, version: version) }
        submittedAt = decoder.decodeOptionalKey("submittedAt")
        featuredAt = decoder.decodeOptionalKey("featuredAt")
        unfeaturedAt = decoder.decodeOptionalKey("unfeaturedAt")
        removedAt = decoder.decodeOptionalKey("removedAt")
        categoryPartial = decoder.decodeOptionalKey("categoryPartial")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(status.rawValue, forKey: "status")
        encoder.encodeObject(actions.map { $0.encodeable }, forKey: "actions")
        encoder.encodeObject(submittedAt, forKey: "submittedAt")
        encoder.encodeObject(featuredAt, forKey: "featuredAt")
        encoder.encodeObject(unfeaturedAt, forKey: "unfeaturedAt")
        encoder.encodeObject(removedAt, forKey: "removedAt")
        encoder.encodeObject(categoryPartial, forKey: "categoryPartial")
        super.encode(with: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> CategoryPost {
        let json = JSON(data)
        var actions: [CategoryPost.Action] = []
        if let actionsJson = json["actions"].dictionary {
            for (name, actionJson) in actionsJson {
                guard let action = CategoryPost.Action(name: name, json: actionJson) else { continue }
                actions.append(action)
            }
        }

        let submittedAt = json["submitted_at"].stringValue.toDate() ?? Globals.now
        let featuredAt = json["featured_at"].stringValue.toDate() ?? Globals.now
        let unfeaturedAt = json["unfeatured_at"].stringValue.toDate() ?? Globals.now
        let removedAt = json["removed_at"].stringValue.toDate() ?? Globals.now

        var categoryPartial: CategoryPartial?
        if let categoryId = json["category_id"].string,
            let categoryName = json["category_name"].string,
            let categorySlug = json["category_slug"].string
        {
            categoryPartial = CategoryPartial(id: categoryId, name: categoryName, slug: categorySlug)
        }

        let categoryPost = CategoryPost(
            id: json["id"].idValue,
            categoryPartial: categoryPartial,
            status: CategoryPost.Status(rawValue: json["status"].stringValue) ?? .unspecified,
            actions: actions,
            submittedAt: submittedAt,
            featuredAt: featuredAt,
            unfeaturedAt: unfeaturedAt,
            removedAt: removedAt
        )

        categoryPost.mergeLinks(json["links"].dictionaryObject)

        return categoryPost
    }
}

extension CategoryPost {
    func hasAction(_ name: CategoryPost.Action.Name) -> Bool {
        return actions.any { $0.name == name }
    }
}

extension CategoryPost: JSONSaveable {
    var uniqueId: String? { return "CategoryPost-\(id)" }
    var tableId: String? { return id }
}

extension CategoryPost.Action {
    var encodeable: [String: Any] {
        let parameters: [String: Any] = request.parameters ?? [:]
        return [
            "name": name.rawValue,
            "label": label,
            "url": request.url,
            "method": request.method.rawValue,
            "parameters": parameters,
        ]
    }

    static func decode(_ decodeable: [String: Any], version: Int) -> CategoryPost.Action? {
        guard
            let nameStr = decodeable["name"] as? String,
            let label = decodeable["label"] as? String,
            let url = decodeable["url"] as? URL,
            let method = (decodeable["method"] as? String).flatMap({ Moya.Method(rawValue: $0) }),
            let parameters = decodeable["parameters"] as? [String: String],
            let name = Name(rawValue: nameStr)
        else { return nil }

        return CategoryPost.Action(name: name, label: label, request: ElloRequest(url: url, method: method, parameters: parameters))
    }
}
