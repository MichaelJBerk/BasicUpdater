//
//  GitHub.swift
//  
//
//  Created by Michael Berk on 2/16/23.
//

import Foundation

public struct GithubRelease: Codable {
	///Name of the release
	public var name: String
	///Whether or not the release a is a draft (unpublished) release
	public var draft: Bool
	///Whether or not the release is identified as a prerelease or full release
	public var prerelease: Bool
	///The name of the tag.
	public var tagName: String
	
	public var body: String
	///Specifies the commitish value that determines where the Git tag is created from.
	public var targetCommitish: String
	///The URL of the release discussion.
	public var discussionURL: URL?
	
	public var createdAt, publishedAt: Date?
	public var uploadURL: String
	public var assetsURL, htmlURL: URL
	public var id: Int
	public var nodeId: String
	public var assets: [GithubAsset]
	public var author: GithubUser
	
	enum CodingKeys: String, CodingKey {
		case name, draft, assets, id, body, prerelease, author
		case tagName = "tag_name"
		case assetsURL = "assets_url"
		case uploadURL = "upload_url"
		case htmlURL = "html_url"
		case nodeId = "node_id"
		case createdAt = "created_at"
		case publishedAt = "published_at"
		case targetCommitish = "target_commitish"
		case discussionURL = "discussions_url"
	}
}
///A Github User
public struct GithubUser: Codable {
	public var name, email: String?
	public var login: String
	public var id: Int
	public var nodeId: String
	public var gravatarId: String
	public var avatarURL, htmlURL: URL
	
	enum CodingKeys: String, CodingKey {
		case name, email, login, id
		case nodeId = "node_id"
		case gravatarId = "gravatar_id"
		case avatarURL = "avatar_url"
		case htmlURL = "html_url"
	}
}

///An asset for a GitHub release
public struct GithubAsset: Codable {
	public var browserDownloadURL: URL
	public var url: URL
	public var id: Int
	public var nodeId: String
	///The file name of the asset.
	public var name: String
	
	public var contentType: String
	public var size, downloadCount: Int
	public var createdAt, updatedAt: Date
	public var state: AssetState
	
	///State of the release asset.
	public enum AssetState: String, Codable {
		case uploaded
		case open
	}
	
	
	enum CodingKeys: String, CodingKey {
		case url, id, name, size, state
		case downloadCount = "download_count"
		case contentType = "content_type"
		case nodeId = "node_id"
		case browserDownloadURL = "browser_download_url"
		case createdAt = "created_at"
		case updatedAt = "updated_at"
		
	}
}
